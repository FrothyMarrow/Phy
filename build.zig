const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .Debug,
    });

    const phy = b.addExecutable(.{
        .name = "phy",
        .link_libc = true,
        .optimize = mode,
        .target = target,
    });

    phy.defineCMacro("GL_SILENCE_DEPRECATION", &.{});
    phy.defineCMacro("GLFW_INCLUDE_GLCOREARB", &.{});

    phy.addIncludePath(.{
        .src_path = .{ .owner = b, .sub_path = "include" },
    });
    phy.addCSourceFiles(.{
        .root = .{
            .src_path = .{ .owner = b, .sub_path = "src" },
        },
        .files = &.{
            "main.c",
            "vector.c",
        },
    });
    phy.linkSystemLibrary("glfw");
    phy.linkFramework("OpenGL");

    b.installArtifact(phy);

    const phy_run = b.addRunArtifact(phy);
    const run_step = b.step("run", "Run the phy binary");
    run_step.dependOn(&phy_run.step);
}
