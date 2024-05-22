const std = @import("std");
const c = @cImport({
    @cInclude("OpenGL/gl3.h");
});

const Color = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

const Renderer = struct {
    pub fn clearColor(_: *Renderer, color: Color) void {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glClearColor(color.r, color.g, color.b, color.a);
    }
};

const RendererError = error{
    FailedToAllocateRenderer,
};

pub fn create(allocator: std.mem.Allocator) RendererError!*Renderer {
    const renderer = allocator.create(Renderer) catch {
        std.debug.print("Failed to allocate Renderer\n", .{});
        return RendererError.FailedToAllocateRenderer;
    };
    return renderer;
}
