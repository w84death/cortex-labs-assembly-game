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
    const game_raw_dos = b.pathJoin(&.{ bin_dir, "game12_raw_dos.com" });
    const game_com_dos = b.pathJoin(&.{ bin_dir, "game12_dos.com" });
    const game_raw_floppy = b.pathJoin(&.{ bin_dir, "game12_raw_floppy.com" });
    const game_com_floppy = b.pathJoin(&.{ bin_dir, "game12_floppy.com" });
    const floppy_img = b.pathJoin(&.{ img_dir, "floppy.img" });

    // Source files
    const boot_asm = "src/boot.asm";
    const game_asm = "src/game.asm";

    // Manual file
    const manual_txt = "MANUAL.TXT";
    const jsdos_archive = "jsdos/game12.jsdos";

    // DOSBox bundle templates
    const bundle_conf = "packaging/dosbox.conf";
    const bundle_run_bat = "packaging/run.bat";
    const bundle_run_sh = "packaging/run.sh";

    // Bundled DOSBox runtime source paths
    const dosbox_windows_src = "third_party/dosbox/windows";
    const dosbox_linux_src = "third_party/dosbox/linux";

    // Release bundle outputs
    const release_dir = b.pathJoin(&.{ build_dir, "release" });
    const bundle_windows_dir = b.pathJoin(&.{ release_dir, "Cortex-Labs-windows" });
    const bundle_linux_dir = b.pathJoin(&.{ release_dir, "Cortex-Labs-linux" });
    const bundle_windows_game_dir = b.pathJoin(&.{ bundle_windows_dir, "game" });
    const bundle_linux_game_dir = b.pathJoin(&.{ bundle_linux_dir, "game" });
    const package_windows_zip = b.pathJoin(&.{ release_dir, "Cortex-Labs-windows.zip" });
    const package_linux_tgz = b.pathJoin(&.{ release_dir, "Cortex-Labs-linux.tar.gz" });

    // USB floppy device (change this to match your system)
    const usb_floppy = "/dev/sdb";

    // Create directories step
    const mkdir_bin = b.addSystemCommand(&.{ "mkdir", "-p", bin_dir });
    const mkdir_img = b.addSystemCommand(&.{ "mkdir", "-p", img_dir });
    const mkdir_release = b.addSystemCommand(&.{ "mkdir", "-p", release_dir });

    // Build bootloader
    const build_boot = b.addSystemCommand(&.{ "fasm", boot_asm, boot_bin });
    build_boot.step.dependOn(&mkdir_bin.step);

    // Build DOS game (raw COM file, no mouse driver)
    const build_game_dos = b.addSystemCommand(&.{ "fasm", "-dINCLUDE_MOUSE_DRIVER=0", game_asm, game_raw_dos });
    build_game_dos.step.dependOn(&mkdir_bin.step);

    // Build floppy game (raw COM file, with mouse driver)
    const build_game_floppy = b.addSystemCommand(&.{ "fasm", "-dINCLUDE_MOUSE_DRIVER=1", game_asm, game_raw_floppy });
    build_game_floppy.step.dependOn(&mkdir_bin.step);

    // Compress with UPX and add P1X signature
    const compress_dos_cmd = b.fmt("cp {s} {s} && upx --best {s} && echo -n 'P1X' >> {s}", .{
        game_raw_dos, game_com_dos, game_com_dos, game_com_dos,
    });
    const compress_game_dos = b.addSystemCommand(&.{ "sh", "-c", compress_dos_cmd });
    compress_game_dos.step.dependOn(&build_game_dos.step);

    const compress_floppy_cmd = b.fmt("cp {s} {s} && upx --best {s} && echo -n 'P1X' >> {s}", .{
        game_raw_floppy, game_com_floppy, game_com_floppy, game_com_floppy,
    });
    const compress_game_floppy = b.addSystemCommand(&.{ "sh", "-c", compress_floppy_cmd });
    compress_game_floppy.step.dependOn(&build_game_floppy.step);

    // Create floppy image
    const floppy_cmd = b.fmt("dd if=/dev/zero of={0s} bs=512 count=2880 2>/dev/null && mformat -i {0s} -f 1440 -v CORTEX -B {1s} :: && mcopy -i {0s} {2s} ::GAME.COM && mcopy -i {0s} {3s} ::MANUAL.TXT 2>/dev/null || true && echo 'Floppy contents:' && mdir -i {0s} ::", .{ floppy_img, boot_bin, game_com_floppy, manual_txt });
    const create_floppy = b.addSystemCommand(&.{ "sh", "-c", floppy_cmd });
    create_floppy.step.dependOn(&build_boot.step);
    create_floppy.step.dependOn(&compress_game_floppy.step);
    create_floppy.step.dependOn(&mkdir_img.step);

    // Default step: build floppy image
    const all_step = b.step("all", "Build FAT12 bootable floppy image (default)");
    all_step.dependOn(&create_floppy.step);

    // Build just the compressed COM file
    const com_step = b.step("com", "Build compressed COM file with UPX");
    com_step.dependOn(&compress_game_dos.step);

    // Build just the raw COM file
    const com_raw_step = b.step("com-raw", "Build uncompressed COM file");
    com_raw_step.dependOn(&build_game_dos.step);

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
    const jsdos_cmd = b.fmt("cp {0s} game.com && zip -u {1s} game.com && rm game.com && echo 'jsdos build complete: {1s}'", .{ game_com_dos, jsdos_archive });
    const build_jsdos = b.addSystemCommand(&.{ "sh", "-c", jsdos_cmd });
    build_jsdos.step.dependOn(&compress_game_dos.step);
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
        .{ boot_bin, game_raw_dos, game_com_dos, floppy_img },
    );
    const show_stats = b.addSystemCommand(&.{ "sh", "-c", stats_cmd });
    show_stats.step.dependOn(&build_boot.step);
    show_stats.step.dependOn(&compress_game_dos.step);
    show_stats.step.dependOn(&build_game_dos.step);
    const stats_step = b.step("stats", "Display project statistics");
    stats_step.dependOn(&show_stats.step);

    // Build tools
    const tools_step = b.step("tools", "Build rleimg2asm tool");
    const build_rleimg2asm = b.addSystemCommand(&.{
        "zig",
        "build-exe",
        "tools/rleimg2asm/rleimg2asm.zig",
        "-O",
        "ReleaseFast",
        "-lc",
        "-lpng16",
        "-I/usr/include/libpng16",
        "-femit-bin=tools/rleimg2asm/rleimg2asm",
    });
    tools_step.dependOn(&build_rleimg2asm.step);

    // Decompress COM file
    const decompress_cmd = b.fmt("if upx -t {0s} >/dev/null 2>&1; then echo 'Decompressing {0s}...'; upx -d {0s}; echo 'File decompressed successfully'; else echo '{0s} is not UPX compressed'; fi", .{game_com_dos});
    const decompress = b.addSystemCommand(&.{ "sh", "-c", decompress_cmd });
    decompress.step.dependOn(&compress_game_dos.step);
    const decompress_step = b.step("decompress", "Decompress COM file for debugging");
    decompress_step.dependOn(&decompress.step);

    // Test UPX compression
    const test_upx_cmd = b.fmt("echo 'Testing UPX compression ratios...' && cp {0s} /tmp/test_upx.com && echo 'Original size: '$(stat -c%s /tmp/test_upx.com 2>/dev/null || stat -f%z /tmp/test_upx.com 2>/dev/null)' bytes' && echo '' && echo 'UPX --fast:' && cp {0s} /tmp/test_upx_fast.com && upx --fast /tmp/test_upx_fast.com 2>/dev/null && echo 'UPX --best:' && cp {0s} /tmp/test_upx_best.com && upx --best /tmp/test_upx_best.com 2>/dev/null && echo 'UPX --ultra-brute:' && cp {0s} /tmp/test_upx_ultra.com && upx --ultra-brute /tmp/test_upx_ultra.com 2>/dev/null || echo 'Ultra-brute compression failed or not supported' && rm -f /tmp/test_upx*.com", .{game_raw_dos});
    const test_upx = b.addSystemCommand(&.{ "sh", "-c", test_upx_cmd });
    test_upx.step.dependOn(&build_game_dos.step);
    const test_upx_step = b.step("test-upx", "Test different UPX compression levels");
    test_upx_step.dependOn(&test_upx.step);

    // Check UPX compression
    const check_upx_cmd = b.fmt("if upx -t {0s} >/dev/null 2>&1; then echo '{0s} is UPX compressed'; upx -l {0s}; else echo '{0s} is not UPX compressed'; fi", .{game_com_dos});
    const check_upx = b.addSystemCommand(&.{ "sh", "-c", check_upx_cmd });
    check_upx.step.dependOn(&compress_game_dos.step);
    const check_upx_step = b.step("check-upx", "Check if COM file is UPX compressed");
    check_upx_step.dependOn(&check_upx.step);

    // DOSBox portable bundle (Windows)
    const bundle_windows_cmd = b.fmt(
        "set -e && " ++
            "if [ ! -d {0s} ]; then echo 'Missing DOSBox runtime directory: {0s}'; echo 'Put Windows DOSBox files there (dosbox.exe and required DLLs).'; exit 1; fi && " ++
            "rm -rf {1s} && mkdir -p {2s} && " ++
            "cp {3s} {2s}/GAME.COM && " ++
            "if [ -f {4s} ]; then cp {4s} {2s}/MANUAL.TXT; fi && " ++
            "cp {5s} {1s}/dosbox.conf && " ++
            "cp {6s} {1s}/run.bat && " ++
            "cp -a {0s}/. {1s}/dosbox/ && " ++
            "cp LICENSE {1s}/LICENSE",
        .{ dosbox_windows_src, bundle_windows_dir, bundle_windows_game_dir, game_com_dos, manual_txt, bundle_conf, bundle_run_bat },
    );
    const bundle_windows = b.addSystemCommand(&.{ "sh", "-c", bundle_windows_cmd });
    bundle_windows.step.dependOn(&compress_game_dos.step);
    bundle_windows.step.dependOn(&mkdir_release.step);

    // DOSBox portable bundle (Linux)
    const bundle_linux_cmd = b.fmt(
        "set -e && " ++
            "if [ ! -d {0s} ]; then echo 'Missing DOSBox runtime directory: {0s}'; echo 'Put Linux DOSBox files there (dosbox binary and required libs).'; exit 1; fi && " ++
            "rm -rf {1s} && mkdir -p {2s} && " ++
            "cp {3s} {2s}/GAME.COM && " ++
            "if [ -f {4s} ]; then cp {4s} {2s}/MANUAL.TXT; fi && " ++
            "cp {5s} {1s}/dosbox.conf && " ++
            "cp {6s} {1s}/run.sh && chmod +x {1s}/run.sh && " ++
            "cp -a {0s}/. {1s}/dosbox/ && " ++
            "cp LICENSE {1s}/LICENSE",
        .{ dosbox_linux_src, bundle_linux_dir, bundle_linux_game_dir, game_com_dos, manual_txt, bundle_conf, bundle_run_sh },
    );
    const bundle_linux = b.addSystemCommand(&.{ "sh", "-c", bundle_linux_cmd });
    bundle_linux.step.dependOn(&compress_game_dos.step);
    bundle_linux.step.dependOn(&mkdir_release.step);

    const bundle_windows_step = b.step("bundle-windows", "Build portable DOSBox bundle for Windows");
    bundle_windows_step.dependOn(&bundle_windows.step);

    const bundle_linux_step = b.step("bundle-linux", "Build portable DOSBox bundle for Linux");
    bundle_linux_step.dependOn(&bundle_linux.step);

    const bundle_step = b.step("bundle", "Build portable DOSBox bundles for Windows and Linux");
    bundle_step.dependOn(&bundle_windows.step);
    bundle_step.dependOn(&bundle_linux.step);

    // Release archives
    const package_windows_cmd = b.fmt("set -e && rm -f {0s} && cd {1s} && zip -r Cortex-Labs-windows.zip Cortex-Labs-windows", .{ package_windows_zip, release_dir });
    const package_windows = b.addSystemCommand(&.{ "sh", "-c", package_windows_cmd });
    package_windows.step.dependOn(&bundle_windows.step);

    const package_linux_cmd = b.fmt("set -e && rm -f {0s} && cd {1s} && tar -czf Cortex-Labs-linux.tar.gz Cortex-Labs-linux", .{ package_linux_tgz, release_dir });
    const package_linux = b.addSystemCommand(&.{ "sh", "-c", package_linux_cmd });
    package_linux.step.dependOn(&bundle_linux.step);

    const package_windows_step = b.step("package-windows", "Create Cortex-Labs-windows.zip");
    package_windows_step.dependOn(&package_windows.step);

    const package_linux_step = b.step("package-linux", "Create Cortex-Labs-linux.tar.gz");
    package_linux_step.dependOn(&package_linux.step);

    const package_step = b.step("package", "Create release archives for Windows and Linux bundles");
    package_step.dependOn(&package_windows.step);
    package_step.dependOn(&package_linux.step);

    // Opcode usage stats (from ASM sources)
    const opcodes_cmd =
        "echo '================================================' && " ++
        "echo ' OPCODE USAGE (MOST -> LEAST)' && " ++
        "echo '================================================' && " ++
        "awk '\n" ++
        "BEGIN {\n" ++
        "  split(\"aaa aad aam aas adc add and call cbw cdq clc cld cli cmc cmp cmpsb cmpsw cwd daa das dec div hlt idiv imul in inc int into iret ja jae jb jbe jc je jg jge jl jle jmp jna jnae jnb jnbe jnc jne jng jnge jnl jnle jno jnp jns jnz jo jp jpe jpo js jz lahf lds lea les lodsb lodsw loop loopz loopnz loope loopne mov movsb movsw movsd movsx movzx mul neg nop not or out pop popa popf push pusha pushf rcl rcr ret rol ror sahf sal sar sbb scasb scasw shl shr stc std sti sub test xchg xlat xlatb xor rep repe repne repnz repz\", m, \" \")\n" ++
        "  for (i in m) op[m[i]] = 1\n" ++
        "}\n" ++
        "{\n" ++
        "  line=$0\n" ++
        "  sub(/;.*/, \"\", line)\n" ++
        "  gsub(/^[ \\t]+|[ \\t]+$/, \"\", line)\n" ++
        "  if (line == \"\") next\n" ++
        "  while (match(line, /^[A-Za-z_.$?][A-Za-z0-9_.$?]*:[ \\t]*/)) {\n" ++
        "    line = substr(line, RSTART + RLENGTH)\n" ++
        "  }\n" ++
        "  gsub(/^[ \\t]+/, \"\", line)\n" ++
        "  if (line == \"\") next\n" ++
        "  split(line, a, /[ \\t]+/)\n" ++
        "  tok = tolower(a[1])\n" ++
        "  if (!(tok in op)) next\n" ++
        "  count[tok]++\n" ++
        "  total++\n" ++
        "}\n" ++
        "END {\n" ++
        "  uniq = 0\n" ++
        "  for (k in count) uniq++\n" ++
        "  for (k in count) printf \"%7d  %s\\n\", count[k], k | \"sort -nr\"\n" ++
        "  close(\"sort -nr\")\n" ++
        "  print \"\"\n" ++
        "  printf \"TOTAL OPCODE INSTANCES: %d\\n\", total\n" ++
        "  printf \"UNIQUE OPCODES: %d\\n\", uniq\n" ++
        "  print \"================================================\"\n" ++
        "}\n" ++
        "' src/*.asm";
    const show_opcodes = b.addSystemCommand(&.{ "sh", "-c", opcodes_cmd });
    const opcodes_step = b.step("opcodes", "List opcode usage frequency");
    opcodes_step.dependOn(&show_opcodes.step);

    // Clean build artifacts
    const clean = b.addSystemCommand(&.{ "rm", "-rf", build_dir });
    const clean_step = b.step("clean", "Remove build artifacts");
    clean_step.dependOn(&clean.step);

    // Clean tools
    const clean_tools_step = b.step("clean-tools", "Clean rleimg2asm tool");
    const clean_rleimg2asm = b.addSystemCommand(&.{ "rm", "-f", "tools/rleimg2asm/rleimg2asm" });
    clean_tools_step.dependOn(&clean_rleimg2asm.step);

    // Help - show available steps
    const help_step = b.step("help", "Show help message");
    const show_help = b.addSystemCommand(&.{
        "sh",                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                "-c",
        "echo 'GAME-12 Build Targets:' && echo '  all            - Build FAT12 bootable floppy image (default)' && echo '  com            - Build compressed COM file with UPX' && echo '  com-raw        - Build uncompressed COM file' && echo '  bochs          - Run in Bochs debugger' && echo '  qemu           - Run in QEMU emulator' && echo '  jsdos          - Build jsdos archive' && echo '  burn           - Burn to physical floppy' && echo '  stats          - Display project statistics' && echo '  opcodes        - List opcode usage frequency' && echo '  tools          - Build rleimg2asm tool' && echo '  clean          - Remove build artifacts' && echo '  clean-tools    - Clean rleimg2asm tool' && echo '' && echo 'DOSBox Bundle Targets:' && echo '  bundle-windows - Build Cortex-Labs-windows bundle' && echo '  bundle-linux   - Build Cortex-Labs-linux bundle' && echo '  bundle         - Build both OS bundles' && echo '  package-windows - Create Cortex-Labs-windows.zip' && echo '  package-linux  - Create Cortex-Labs-linux.tar.gz' && echo '  package        - Create both release archives' && echo '' && echo 'UPX Compression Targets:' && echo '  decompress     - Decompress COM file for debugging' && echo '  test-upx       - Test different UPX compression levels' && echo '  check-upx      - Check if COM file is UPX compressed' && echo '' && echo 'Development Tools:' && echo '  rleimg2asm     - Convert images to RLE-compressed assembly' && echo '' && echo 'The floppy image is DOS-compatible and contains:' && echo '  GAME.COM       - The game executable' && echo '  MANUAL.TXT     - Game manual'",
    });
    help_step.dependOn(&show_help.step);
}
