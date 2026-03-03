const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.standardTargetOptions(.{});
    _ = b.standardOptimizeOption(.{});

    // Build directories
    const build_dir = "build";
    const bin_dir = b.pathJoin(&.{ build_dir, "bin" });
    const img_dir = b.pathJoin(&.{ build_dir, "img" });

    // Output files
    const boot_bin = b.pathJoin(&.{ bin_dir, "boot.bin" });
    const game_raw = b.pathJoin(&.{ bin_dir, "game12_raw.com" });
    const game_com = b.pathJoin(&.{ bin_dir, "game12.com" });
    const floppy_img = b.pathJoin(&.{ img_dir, "floppy.img" });

    // Source files
    const boot_asm = "src/boot.asm";
    const game_asm = "src/game.asm";

    // Manual file
    const manual_txt = "MANUAL.TXT";
    const jsdos_archive = "jsdos/game12.jsdos";

    // USB floppy device (change this to match your system)
    const usb_floppy = "/dev/sdb";

    // Create directories step
    const mkdir_bin = b.addSystemCommand(&.{ "mkdir", "-p", bin_dir });
    const mkdir_img = b.addSystemCommand(&.{ "mkdir", "-p", img_dir });

    // Build bootloader
    const build_boot = b.addSystemCommand(&.{ "fasm", boot_asm, boot_bin });
    build_boot.step.dependOn(&mkdir_bin.step);

    // Build game (raw COM file)
    const build_game = b.addSystemCommand(&.{ "fasm", game_asm, game_raw });
    build_game.step.dependOn(&mkdir_bin.step);

    // Compress with UPX and add P1X signature
    const compress_cmd = b.fmt("cp {s} {s} && upx --best {s} && echo -n 'P1X' >> {s}", .{
        game_raw, game_com, game_com, game_com,
    });
    const compress_game = b.addSystemCommand(&.{ "sh", "-c", compress_cmd });
    compress_game.step.dependOn(&build_game.step);

    // Create floppy image
    const floppy_cmd = b.fmt("dd if=/dev/zero of={0s} bs=512 count=2880 2>/dev/null && mformat -i {0s} -f 1440 -v CORTEX -B {1s} :: && mcopy -i {0s} {2s} ::GAME.COM && mcopy -i {0s} {3s} ::MANUAL.TXT 2>/dev/null || true && echo 'Floppy contents:' && mdir -i {0s} ::", .{ floppy_img, boot_bin, game_com, manual_txt });
    const create_floppy = b.addSystemCommand(&.{ "sh", "-c", floppy_cmd });
    create_floppy.step.dependOn(&build_boot.step);
    create_floppy.step.dependOn(&compress_game.step);
    create_floppy.step.dependOn(&mkdir_img.step);

    // Default step: build floppy image
    const all_step = b.step("all", "Build FAT12 bootable floppy image (default)");
    all_step.dependOn(&create_floppy.step);

    // Build just the compressed COM file
    const com_step = b.step("com", "Build compressed COM file with UPX");
    com_step.dependOn(&compress_game.step);

    // Build just the raw COM file
    const com_raw_step = b.step("com-raw", "Build uncompressed COM file");
    com_raw_step.dependOn(&build_game.step);

    // Run in Bochs
    const bochs_step = b.step("bochs", "Run in Bochs debugger");
    const run_bochs = b.addSystemCommand(&.{ "bochs", "-q", "-f", ".bochsrc" });
    run_bochs.step.dependOn(&create_floppy.step);
    bochs_step.dependOn(&run_bochs.step);

    // Run in QEMU
    const qemu_step = b.step("qemu", "Run in QEMU emulator");
    const qemu_drive = b.fmt("format=raw,file={s},if=floppy", .{floppy_img});
    const run_qemu = b.addSystemCommand(&.{
        "qemu-system-i386",
        "-drive",
        qemu_drive,
        "-boot",
        "a",
    });
    run_qemu.step.dependOn(&create_floppy.step);
    qemu_step.dependOn(&run_qemu.step);

    // Build jsdos archive
    const jsdos_cmd = b.fmt("cp {0s} game.com && zip -u {1s} game.com && rm game.com && echo 'jsdos build complete: {1s}'", .{ game_com, jsdos_archive });
    const build_jsdos = b.addSystemCommand(&.{ "sh", "-c", jsdos_cmd });
    build_jsdos.step.dependOn(&compress_game.step);
    const jsdos_step = b.step("jsdos", "Build jsdos archive");
    jsdos_step.dependOn(&build_jsdos.step);

    // Burn to physical floppy
    const burn_cmd = b.fmt("echo 'WARNING: This will overwrite all data on {0s}!' && echo 'Press Ctrl+C to cancel, or Enter to continue...' && read dummy && sudo dd if={1s} of={0s} bs=512 conv=notrunc,sync,fsync oflag=direct status=progress && echo 'Successfully burned to {0s}'", .{ usb_floppy, floppy_img });
    const burn_floppy = b.addSystemCommand(&.{ "sh", "-c", burn_cmd });
    burn_floppy.step.dependOn(&create_floppy.step);
    const burn_step = b.step("burn", "Burn to physical floppy disk");
    burn_step.dependOn(&burn_floppy.step);

    // Display statistics
    const stats_cmd = b.fmt(
        "echo '================================================' && echo ' GAME-12 PROJECT STATISTICS' && echo '================================================' && echo '' && echo 'BINARY SIZES:' && echo ' Boot sector: '$(stat -c%s {0s} 2>/dev/null || stat -f%z {0s} 2>/dev/null)' bytes' && raw_size=$(stat -c%s {1s} 2>/dev/null || stat -f%z {1s} 2>/dev/null) && compressed_size=$(stat -c%s {2s} 2>/dev/null || stat -f%z {2s} 2>/dev/null) && ratio=$((100 - (compressed_size * 100 / raw_size))) && echo ' Game COM (raw): '$raw_size' bytes' && echo ' Game COM (UPX): '$compressed_size' bytes ('$ratio'%% reduction)' && if [ -f {3s} ]; then echo ' Floppy image: '$(stat -c%s {3s} 2>/dev/null || stat -f%z {3s} 2>/dev/null)' bytes'; fi && echo '' && echo 'Lines of Code (all files in /src/):' && for file in src/*.asm; do if [ -f \"$file\" ]; then lines=$(grep -v '^[[:space:]]*$' \"$file\" | grep -v '^[[:space:]]*;' | wc -l); basename=$(basename \"$file\"); printf ' %-20s %5s lines\\n' \"$basename\" \"$lines\"; fi; done && echo '' && echo 'Total LOC:' $(cat src/*.asm | grep -v '^[[:space:]]*$' | grep -v '^[[:space:]]*;' | wc -l) && echo '' && echo 'Comment Coverage (main files only):' && for file in src/boot.asm src/game.asm; do if [ -f \"$file\" ]; then basename=$(basename \"$file\"); total_lines=$(grep -v '^[[:space:]]*$' \"$file\" | grep -v '^[[:space:]]*;' | wc -l); comment_lines=$(grep -c '^[[:space:]]*;' \"$file\" || true); if [ \"$total_lines\" -gt 0 ]; then coverage=$((comment_lines * 100 / total_lines)); printf ' %-20s %5s/%5s (%s%%)\\n' \"$basename\" \"$comment_lines\" \"$total_lines\" \"$coverage\"; fi; fi; done && echo '================================================'",
        .{ boot_bin, game_raw, game_com, floppy_img },
    );
    const show_stats = b.addSystemCommand(&.{ "sh", "-c", stats_cmd });
    show_stats.step.dependOn(&build_boot.step);
    show_stats.step.dependOn(&compress_game.step);
    show_stats.step.dependOn(&build_game.step);
    const stats_step = b.step("stats", "Display project statistics");
    stats_step.dependOn(&show_stats.step);

    // Build tools
    const tools_step = b.step("tools", "Build all development tools");
    const build_fnt2asm = b.addSystemCommand(&.{ "make", "-C", "tools/fnt2asm" });
    const build_png2asm = b.addSystemCommand(&.{ "make", "-C", "tools/png2asm" });
    const build_rleimg2asm = b.addSystemCommand(&.{ "make", "-C", "tools/rleimg2asm" });
    tools_step.dependOn(&build_fnt2asm.step);
    tools_step.dependOn(&build_png2asm.step);
    tools_step.dependOn(&build_rleimg2asm.step);

    // Decompress COM file
    const decompress_cmd = b.fmt("if upx -t {0s} >/dev/null 2>&1; then echo 'Decompressing {0s}...'; upx -d {0s}; echo 'File decompressed successfully'; else echo '{0s} is not UPX compressed'; fi", .{game_com});
    const decompress = b.addSystemCommand(&.{ "sh", "-c", decompress_cmd });
    decompress.step.dependOn(&compress_game.step);
    const decompress_step = b.step("decompress", "Decompress COM file for debugging");
    decompress_step.dependOn(&decompress.step);

    // Test UPX compression
    const test_upx_cmd = b.fmt("echo 'Testing UPX compression ratios...' && cp {0s} /tmp/test_upx.com && echo 'Original size: '$(stat -c%s /tmp/test_upx.com 2>/dev/null || stat -f%z /tmp/test_upx.com 2>/dev/null)' bytes' && echo '' && echo 'UPX --fast:' && cp {0s} /tmp/test_upx_fast.com && upx --fast /tmp/test_upx_fast.com 2>/dev/null && echo 'UPX --best:' && cp {0s} /tmp/test_upx_best.com && upx --best /tmp/test_upx_best.com 2>/dev/null && echo 'UPX --ultra-brute:' && cp {0s} /tmp/test_upx_ultra.com && upx --ultra-brute /tmp/test_upx_ultra.com 2>/dev/null || echo 'Ultra-brute compression failed or not supported' && rm -f /tmp/test_upx*.com", .{game_raw});
    const test_upx = b.addSystemCommand(&.{ "sh", "-c", test_upx_cmd });
    test_upx.step.dependOn(&build_game.step);
    const test_upx_step = b.step("test-upx", "Test different UPX compression levels");
    test_upx_step.dependOn(&test_upx.step);

    // Check UPX compression
    const check_upx_cmd = b.fmt("if upx -t {0s} >/dev/null 2>&1; then echo '{0s} is UPX compressed'; upx -l {0s}; else echo '{0s} is not UPX compressed'; fi", .{game_com});
    const check_upx = b.addSystemCommand(&.{ "sh", "-c", check_upx_cmd });
    check_upx.step.dependOn(&compress_game.step);
    const check_upx_step = b.step("check-upx", "Check if COM file is UPX compressed");
    check_upx_step.dependOn(&check_upx.step);

    // Clean build artifacts
    const clean = b.addSystemCommand(&.{ "rm", "-rf", build_dir });
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&clean.step);

    // Clean tools
    const clean_tools_step = b.step("clean-tools", "Clean development tools");
    const clean_fnt2asm = b.addSystemCommand(&.{ "make", "-C", "tools/fnt2asm", "clean" });
    const clean_png2asm = b.addSystemCommand(&.{ "make", "-C", "tools/png2asm", "clean" });
    const clean_rleimg2asm = b.addSystemCommand(&.{ "make", "-C", "tools/rleimg2asm", "clean" });
    clean_tools_step.dependOn(&clean_fnt2asm.step);
    clean_tools_step.dependOn(&clean_png2asm.step);
    clean_tools_step.dependOn(&clean_rleimg2asm.step);

    // Help - show available steps
    const help_step = b.step("help", "Show help message");
    const show_help = b.addSystemCommand(&.{
        "sh",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              "-c",
        "echo 'GAME-12 Build Targets:' && echo '  all          - Build FAT12 bootable floppy image (default)' && echo '  com          - Build compressed COM file with UPX' && echo '  com-raw      - Build uncompressed COM file' && echo '  bochs        - Run in Bochs debugger' && echo '  qemu         - Run in QEMU emulator' && echo '  jsdos        - Build jsdos archive' && echo '  burn         - Burn to physical floppy' && echo '  stats        - Display project statistics' && echo '  tools        - Build all development tools' && echo '  clean        - Remove build artifacts' && echo '  clean-tools  - Clean development tools' && echo '' && echo 'UPX Compression Targets:' && echo '  decompress   - Decompress COM file for debugging' && echo '  test-upx     - Test different UPX compression levels' && echo '  check-upx    - Check if COM file is UPX compressed' && echo '' && echo 'Development Tools:' && echo '  fnt2asm      - Convert PNG fonts to assembly data' && echo '  png2asm      - Convert PNG images to assembly data' && echo '  rleimg2asm   - Convert images to RLE-compressed assembly' && echo '' && echo 'The floppy image is DOS-compatible and contains:' && echo '  GAME.COM     - The game executable' && echo '  MANUAL.TXT   - Game manual'",
    });
    help_step.dependOn(&show_help.step);
}
