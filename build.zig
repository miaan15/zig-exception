const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exception_module = b.createModule(.{
        .root_source_file = b.path("src/exception.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exe_root = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_root.addImport("exception", exception_module);

    const exe = b.addExecutable(.{
        .name = "exception",
        .root_module = exe_root,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const main_tests_root = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    main_tests_root.addImport("exception", exception_module);

    const main_tests = b.addTest(.{
        .root_module = main_tests_root,
    });

    const exc_tests_root = b.createModule(.{
        .root_source_file = b.path("src/exception.zig"),
        .target = target,
        .optimize = optimize,
    });

    const exc_tests = b.addTest(.{
        .root_module = exc_tests_root,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    const run_exc_tests = b.addRunArtifact(exc_tests);

    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_main_tests.step);
    test_step.dependOn(&run_exc_tests.step);
}

