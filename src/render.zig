const std = @import("std");
const shader = @import("shader.zig");

const c = @cImport({
    @cInclude("OpenGL/gl3.h");
});

pub const Color = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Renderer = struct {
    pub fn clearColor(_: Renderer, color: Color) void {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glClearColor(color.r, color.g, color.b, color.a);
    }

    pub fn useShader(_: Renderer, shader_program: shader.Shader) void {
        c.glUseProgram(shader_program.program_id);
    }
};

pub fn create() Renderer {
    return Renderer{};
}
