const std = @import("std");
const c = @cImport({
    @cInclude("GLFW/glfw3.h");
});

const WindowSpec = struct {
    title: []const u8,
    width: u32,
    height: u32,
};

pub const Window = struct {
    windowPtr: *c.struct_GLFWwindow,
    spec: WindowSpec,

    pub fn shouldClose(self: *Window) bool {
        return c.glfwWindowShouldClose(self.windowPtr) != 0;
    }

    pub fn swapBuffers(self: *Window) void {
        c.glfwSwapBuffers(self.windowPtr);
    }

    pub fn pollEvents(_: *Window) void {
        c.glfwPollEvents();
    }

    pub fn deinit(self: *Window) void {
        c.glfwDestroyWindow(self.windowPtr);
        c.glfwTerminate();
    }
};

pub const WindowError = error{
    GlfwInitFailed,
    GlfwCreateWindowFailed,
};

pub fn create(allocator: std.mem.Allocator, spec: WindowSpec) WindowError!*Window {
    if (c.glfwInit() == 0) {
        std.debug.print("Failed to initialize GLFW\n", .{});
        return WindowError.GlfwInitFailed;
    }

    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
    c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
    c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
    c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_FALSE);

    _ = c.glfwSetErrorCallback(glfwErrorCallback);

    const window = allocator.create(Window) catch {
        std.debug.print("Failed to allocate Window struct\n", .{});
        return WindowError.GlfwCreateWindowFailed;
    };

    const windowPtr = c.glfwCreateWindow(
        @intCast(spec.width),
        @intCast(spec.height),
        spec.title.ptr,
        null,
        null,
    ) orelse {
        std.debug.print("Failed to create GLFW window\n", .{});
        c.glfwTerminate();
        return WindowError.GlfwCreateWindowFailed;
    };

    c.glfwMakeContextCurrent(windowPtr);

    window.* = .{
        .windowPtr = windowPtr,
        .spec = spec,
    };

    return window;
}

fn glfwErrorCallback(errorCode: c_int, description: [*c]const u8) callconv(.C) void {
    std.debug.print("GLFW error: {}\n", .{errorCode});
    if (description != null) {
        std.debug.print("Description: {?s}\n", .{description});
    }
}