const std = @import("std");

const c = @cImport({
    @cInclude("png.h");
});

const WIDTH: usize = 320;
const HEIGHT: usize = 200;

const Rgb = struct {
    r: u8,
    g: u8,
    b: u8,
};

const dawnbringer_palette = [_]Rgb{
    .{ .r = 0, .g = 0, .b = 0 },
    .{ .r = 68, .g = 32, .b = 52 },
    .{ .r = 48, .g = 52, .b = 109 },
    .{ .r = 78, .g = 74, .b = 78 },
    .{ .r = 133, .g = 76, .b = 48 },
    .{ .r = 52, .g = 101, .b = 36 },
    .{ .r = 208, .g = 70, .b = 72 },
    .{ .r = 117, .g = 113, .b = 97 },
    .{ .r = 89, .g = 125, .b = 206 },
    .{ .r = 210, .g = 125, .b = 44 },
    .{ .r = 133, .g = 149, .b = 161 },
    .{ .r = 109, .g = 170, .b = 44 },
    .{ .r = 210, .g = 170, .b = 153 },
    .{ .r = 109, .g = 194, .b = 202 },
    .{ .r = 218, .g = 212, .b = 94 },
    .{ .r = 222, .g = 238, .b = 214 },
};

fn printUsage(program_name: []const u8) void {
    std.debug.print("Usage: {s} <input.png> <output> [options]\n", .{program_name});
    std.debug.print("Options:\n", .{});
    std.debug.print("  -asm <label>         Output as assembly file with label (default: image_data)\n", .{});
    std.debug.print("  -bin                 Output as raw binary file (default)\n", .{});
    std.debug.print("  -stats               Show compression statistics\n", .{});
    std.debug.print("  -debug               Enable detailed compression output\n", .{});
    std.debug.print("  -preview             Show converted image preview in terminal\n", .{});
    std.debug.print("  -preview-png <file>  Write converted indexed preview as PNG\n", .{});
    std.debug.print("\nNote: Output is interlaced (even lines only, no EOL markers).\n", .{});
}

fn findClosestColor(r: u8, g: u8, b: u8) u8 {
    var best_index: usize = 0;
    var best_distance: i32 = std.math.maxInt(i32);

    for (dawnbringer_palette, 0..) |color, i| {
        const dr: i32 = @as(i32, r) - @as(i32, color.r);
        const dg: i32 = @as(i32, g) - @as(i32, color.g);
        const db: i32 = @as(i32, b) - @as(i32, color.b);
        const distance = dr * dr + dg * dg + db * db;

        if (distance < best_distance) {
            best_distance = distance;
            best_index = i;
        }
    }

    return @intCast(best_index);
}

fn loadPngIndexed(allocator: std.mem.Allocator, filename: []const u8) ![]u8 {
    const c_filename = try allocator.dupeZ(u8, filename);
    defer allocator.free(c_filename);

    var image: c.png_image = std.mem.zeroes(c.png_image);
    image.version = c.PNG_IMAGE_VERSION;

    if (c.png_image_begin_read_from_file(&image, c_filename.ptr) == 0) {
        std.debug.print("Error: failed to read PNG file {s}\n", .{filename});
        return error.PngReadFailed;
    }
    defer c.png_image_free(&image);

    if (image.width != WIDTH or image.height != HEIGHT) {
        std.debug.print("Error: image must be 320x200, got {d}x{d}\n", .{ image.width, image.height });
        return error.InvalidDimensions;
    }

    image.format = c.PNG_FORMAT_RGB;
    const rgb_size: usize = @as(usize, @intCast(image.width)) * @as(usize, @intCast(image.height)) * 3;
    const rgb_pixels = try allocator.alloc(u8, rgb_size);
    defer allocator.free(rgb_pixels);

    if (c.png_image_finish_read(&image, null, rgb_pixels.ptr, 0, null) == 0) {
        std.debug.print("Error: failed to decode PNG pixel data\n", .{});
        return error.PngDecodeFailed;
    }

    const indexed = try allocator.alloc(u8, WIDTH * HEIGHT);
    const channels: usize = 3;
    for (0..HEIGHT) |y| {
        for (0..WIDTH) |x| {
            const src_i = (y * WIDTH + x) * channels;
            const r = rgb_pixels[src_i];
            const g = rgb_pixels[src_i + 1];
            const b = rgb_pixels[src_i + 2];
            indexed[y * WIDTH + x] = findClosestColor(r, g, b);
        }
    }

    return indexed;
}

fn compressScanline(allocator: std.mem.Allocator, line: []const u8, output: *std.ArrayList(u8), line_num: usize, debug: bool) !void {
    var x: usize = 0;
    var run_count: usize = 0;

    if (debug) {
        std.debug.print("Compressing line {d}:\n", .{line_num});
    }

    while (x < WIDTH) {
        const current_color = line[x];
        const max_run = WIDTH - x;
        var run_length: usize = 0;

        while (run_length < max_run and line[x + run_length] == current_color and run_length < 255) {
            run_length += 1;
        }

        if (run_length == 0) {
            std.debug.print("ERROR: zero run length at position {d}\n", .{x});
            run_length = 1;
        }

        try output.append(allocator, @intCast(run_length));
        try output.append(allocator, current_color);

        if (debug) {
            std.debug.print("  Run {d}: start={d}, length={d}, color={d}, end={d}\n", .{ run_count, x, run_length, current_color, x + run_length });
            run_count += 1;
        }

        x += run_length;
    }

    if (x != WIDTH) {
        std.debug.print("ERROR: line {d} encoding mismatch ({d} pixels)\n", .{ line_num, x });
    }
}

fn verifyCompressedData(data: []const u8) usize {
    var pos: usize = 0;
    var line_count: usize = 0;
    const expected_lines = HEIGHT / 2;
    var errors: usize = 0;

    while (pos < data.len and line_count < expected_lines) {
        var line_pixels: usize = 0;

        while (pos < data.len) {
            const run_length = data[pos];
            pos += 1;
            if (pos >= data.len) break;
            _ = data[pos];
            pos += 1;

            if (run_length == 0) {
                std.debug.print("ERROR: zero run length found near byte {d}\n", .{pos - 2});
                errors += 1;
                break;
            }

            line_pixels += run_length;
            if (line_pixels > WIDTH) {
                std.debug.print("ERROR: line {d} exceeds width ({d} pixels)\n", .{ line_count * 2, line_pixels });
                errors += 1;
                break;
            }

            if (line_pixels == WIDTH) break;
        }

        if (line_pixels != WIDTH and line_pixels > 0) {
            std.debug.print("WARNING: line {d} has {d} pixels (expected {d})\n", .{ line_count * 2, line_pixels, WIDTH });
        }

        line_count += 1;
    }

    if (line_count != expected_lines) {
        std.debug.print("ERROR: found {d} lines, expected {d}\n", .{ line_count, expected_lines });
        errors += 1;
    }

    return errors;
}

fn writeAsmOutput(data: []const u8, output_file: []const u8, label_name: []const u8) !void {
    const file = try std.fs.cwd().createFile(output_file, .{ .truncate = true });
    defer file.close();
    var write_buffer: [8192]u8 = undefined;
    var file_writer = file.writer(&write_buffer);
    const writer = &file_writer.interface;

    try writer.print("; Compressed VGA image data (interlaced)\n", .{});
    try writer.print("; Format: [run_length][color_index] pairs\n", .{});
    try writer.print("; Contains only even lines (0, 2, 4...), no EOL markers\n", .{});
    try writer.print("; Assembly code should render each line twice\n", .{});
    try writer.print("; Total size: {d} bytes\n\n", .{data.len});

    try writer.print("{s}:\n", .{label_name});

    for (data, 0..) |value, i| {
        if (i % 16 == 0) {
            if (i > 0) try writer.writeByte('\n');
            try writer.writeAll("    db ");
        } else {
            try writer.writeAll(", ");
        }
        try writer.print("0{X:0>2}h", .{value});
    }
    try writer.writeAll("\n\n");
    try writer.print("{s}_size equ {d}\n", .{ label_name, data.len });
    try writer.print("{s}_end:\n", .{label_name});
    try writer.flush();
}

fn writeBinOutput(data: []const u8, output_file: []const u8) !void {
    const file = try std.fs.cwd().createFile(output_file, .{ .truncate = true });
    defer file.close();
    try file.writeAll(data);
}

fn writePreviewPng(allocator: std.mem.Allocator, indexed: []const u8, output_file: []const u8) !void {
    const rgb = try allocator.alloc(u8, WIDTH * HEIGHT * 3);
    defer allocator.free(rgb);

    for (indexed, 0..) |color_index, i| {
        const color = dawnbringer_palette[color_index];
        const dst = i * 3;
        rgb[dst] = color.r;
        rgb[dst + 1] = color.g;
        rgb[dst + 2] = color.b;
    }

    var image: c.png_image = std.mem.zeroes(c.png_image);
    image.version = c.PNG_IMAGE_VERSION;
    image.width = @intCast(WIDTH);
    image.height = @intCast(HEIGHT);
    image.format = c.PNG_FORMAT_RGB;

    const c_output_file = try allocator.dupeZ(u8, output_file);
    defer allocator.free(c_output_file);

    if (c.png_image_write_to_file(&image, c_output_file.ptr, 0, rgb.ptr, 0, null) == 0) {
        std.debug.print("Error: failed to write preview PNG {s}\n", .{output_file});
        return error.PngWriteFailed;
    }
}

fn showTerminalPreview(indexed: []const u8) !void {
    const stdout_file = std.fs.File.stdout();
    var write_buffer: [8192]u8 = undefined;
    var stdout_writer = stdout_file.writer(&write_buffer);
    const writer = &stdout_writer.interface;
    const step_x: usize = 4;
    const step_y: usize = 4;

    try writer.writeAll("\nConverted image preview (downsampled 4x):\n");
    for (0..HEIGHT / step_y) |yy| {
        const y = yy * step_y;
        for (0..WIDTH / step_x) |xx| {
            const x = xx * step_x;
            const idx = indexed[y * WIDTH + x];
            const color = dawnbringer_palette[idx];
            try writer.print("\x1b[48;2;{d};{d};{d}m  ", .{ color.r, color.g, color.b });
        }
        try writer.writeAll("\x1b[0m\n");
    }
    try writer.writeAll("\x1b[0m\n");
    try writer.flush();
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 3) {
        printUsage(args[0]);
        return;
    }

    const input_file = args[1];
    const output_file = args[2];

    var output_asm = false;
    var show_stats = false;
    var debug_mode = false;
    var show_preview = false;
    var preview_png: ?[]const u8 = null;
    var label_name: []const u8 = "image_data";

    var i: usize = 3;
    while (i < args.len) : (i += 1) {
        const arg = args[i];
        if (std.mem.eql(u8, arg, "-asm")) {
            output_asm = true;
            if (i + 1 < args.len and args[i + 1][0] != '-') {
                i += 1;
                label_name = args[i];
            }
        } else if (std.mem.eql(u8, arg, "-bin")) {
            output_asm = false;
        } else if (std.mem.eql(u8, arg, "-stats")) {
            show_stats = true;
        } else if (std.mem.eql(u8, arg, "-debug")) {
            debug_mode = true;
        } else if (std.mem.eql(u8, arg, "-preview")) {
            show_preview = true;
        } else if (std.mem.eql(u8, arg, "-preview-png")) {
            if (i + 1 >= args.len) {
                std.debug.print("Error: -preview-png requires an output filename\n", .{});
                return;
            }
            i += 1;
            preview_png = args[i];
        } else {
            std.debug.print("Warning: unknown option '{s}' ignored\n", .{arg});
        }
    }

    std.debug.print("Loading PNG: {s}\n", .{input_file});
    const indexed_image = try loadPngIndexed(allocator, input_file);
    defer allocator.free(indexed_image);

    if (show_preview) {
        try showTerminalPreview(indexed_image);
    }

    if (preview_png) |preview_path| {
        std.debug.print("Writing preview PNG: {s}\n", .{preview_path});
        try writePreviewPng(allocator, indexed_image, preview_path);
    }

    std.debug.print("Compressing image (interlaced)...\n", .{});
    var compressed = std.ArrayList(u8).empty;
    defer compressed.deinit(allocator);

    var y: usize = 0;
    while (y < HEIGHT) : (y += 2) {
        const line = indexed_image[y * WIDTH .. (y + 1) * WIDTH];
        try compressScanline(allocator, line, &compressed, y, debug_mode);
    }

    std.debug.print("Verifying compressed data...\n", .{});
    const errors = verifyCompressedData(compressed.items);
    if (errors > 0) {
        std.debug.print("WARNING: found {d} compression errors\n", .{errors});
    }

    if (output_asm) {
        std.debug.print("Writing assembly output: {s}\n", .{output_file});
        try writeAsmOutput(compressed.items, output_file, label_name);
    } else {
        std.debug.print("Writing binary output: {s}\n", .{output_file});
        try writeBinOutput(compressed.items, output_file);
    }

    if (show_stats) {
        const uncompressed_size = WIDTH * HEIGHT;
        const ratio = @as(f64, @floatFromInt(uncompressed_size)) / @as(f64, @floatFromInt(compressed.items.len));
        const reduction = (1.0 - (@as(f64, @floatFromInt(compressed.items.len)) / @as(f64, @floatFromInt(uncompressed_size)))) * 100.0;

        std.debug.print("\nCompression Statistics (Interlaced):\n", .{});
        std.debug.print("  Original size: {d} bytes\n", .{uncompressed_size});
        std.debug.print("  Compressed size: {d} bytes (even lines only)\n", .{compressed.items.len});
        std.debug.print("  Effective compression ratio: {d:.2}:1 ({d:.1}% reduction)\n", .{ ratio, reduction });
        std.debug.print("  Note: Assembly code renders each line twice\n", .{});
    }

    std.debug.print("Done!\n", .{});
}
