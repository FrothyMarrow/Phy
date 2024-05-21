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

    if (std.posix.getenv("IN_NIX_SHELL") != null)
        addGLFromNixCFlags(b, phy);

    phy.linkSystemLibrary("glfw");
    phy.linkFramework("OpenGL");

    b.installArtifact(phy);
}

const LibGLPathError = error{
    NixCompileFlagsNotFound,
    OpenGLFrameworkPathNotFound,
    PathBufferAllocationFailed,
    LibGLPathAssignmentFailed,
};

fn addGLFromNixCFlags(b: *std.Build, bin: *std.Build.Step.Compile) void {
    const libGL_path = getLibGLFromNixCFlags(b) catch |err| {
        std.log.err("Failed to find libGL path: {}\n", .{err});
        return;
    };
    defer b.allocator.free(libGL_path);

    bin.addLibraryPath(.{ .src_path = .{ .owner = b, .sub_path = libGL_path } });
}

fn getLibGLFromNixCFlags(b: *std.Build) LibGLPathError![]const u8 {
    const nix_cflags_compile = std.posix.getenv("NIX_CFLAGS_COMPILE") orelse {
        std.log.warn("NIX_CFLAGS_COMPILE not found\n", .{});
        return LibGLPathError.NixCompileFlagsNotFound;
    };

    const opengl_framework_path = getOpenGLFromNixCFlags(nix_cflags_compile) orelse {
        std.log.warn("OpenGL framework path not found in NIX_CFLAGS_COMPILE\n", .{});
        return LibGLPathError.OpenGLFrameworkPathNotFound;
    };

    const libGL_path = std.fmt.allocPrint(
        b.allocator,
        "{s}/OpenGL.framework/Versions/A/Libraries",
        .{opengl_framework_path},
    ) catch {
        std.log.warn("Failed to allocate buffer for libGL path\n", .{});
        return LibGLPathError.PathBufferAllocationFailed;
    };

    std.fs.accessAbsolute(libGL_path, .{}) catch |err| {
        std.log.warn("Failed to access libGL path: {}\n", .{err});
        return LibGLPathError.LibGLPathAssignmentFailed;
    };

    return libGL_path;
}

fn getOpenGLFromNixCFlags(nix_cflags_compile: []const u8) ?[]const u8 {
    var it = std.mem.split(u8, nix_cflags_compile, " ");

    while (it.next()) |flag|
        if (std.mem.containsAtLeast(u8, flag, 1, "OpenGL"))
            return flag;

    return null;
}
