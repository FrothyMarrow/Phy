const std = @import("std");
const win = @import("window.zig");
const render = @import("render.zig");
const shader = @import("shader.zig");

const c = @cImport({
    @cInclude("OpenGL/gl3.h");
});

const AppError = error{
    WindowCreationError,
    ShaderCreationError,
};

pub fn main() AppError!void {
    const window = win.create(.{ .title = "Phy", .width = 800, .height = 600 }) catch {
        std.debug.print("Failed to create App window\n", .{});
        return error.WindowCreationError;
    };
    defer window.deinit();

    var renderer = render.create();
    defer renderer.deinit();

    const shaderProgram = shader.create(
        "shader/vertex.glsl",
        "shader/fragment.glsl",
    ) catch {
        std.debug.print("Failed to create shader program\n", .{});
        return error.ShaderCreationError;
    };
    defer shaderProgram.deinit();

    renderer.useShader(shaderProgram);

    renderer.drawTriangles(&.{
        0.0,  0.5,  0.0,
        -0.5, -0.5, 0.0,
        0.5,  -0.5, 0.0,
    });

    while (!window.shouldClose()) {
        window.pollEvents();

        renderer.clearColor(.{
            .r = 1.0,
            .g = 0.3,
            .b = 0.3,
            .a = 1.0,
        });

        renderer.render();

        window.swapBuffers();
    }
}
