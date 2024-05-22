const std = @import("std");
const win = @import("window.zig");
const render = @import("render.zig");

const AppError = error{
    WindowCreationError,
    RendererCreationError,
};

pub fn main() AppError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const window = win.create(allocator, .{
        .title = "Phy",
        .width = 800,
        .height = 600,
    }) catch {
        std.debug.print("Failed to create App window\n", .{});
        return error.WindowCreationError;
    };

    defer allocator.destroy(window);
    defer window.deinit();

    const renderer = render.create(allocator) catch {
        std.debug.print("Failed to create App renderer\n", .{});
        return error.RendererCreationError;
    };

    defer allocator.destroy(renderer);

    while (!window.shouldClose()) {
        window.pollEvents();

        renderer.clearColor(.{
            .r = 0.2,
            .g = 0.3,
            .b = 0.3,
            .a = 1.0,
        });

        window.swapBuffers();
    }
}
