const std = @import("std");
const win = @import("window.zig");
const render = @import("render.zig");

const AppError = error{
    WindowCreationError,
};

pub fn main() AppError!void {
    const window = win.create(.{ .title = "Phy", .width = 800, .height = 600 }) catch {
        std.debug.print("Failed to create App window\n", .{});
        return error.WindowCreationError;
    };
    defer window.deinit();

    const renderer = render.create();
    };


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
