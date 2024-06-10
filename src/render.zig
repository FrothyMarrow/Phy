const std = @import("std");
const shader = @import("shader.zig");
const camera = @import("camera.zig");

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
    vertexArray: u32,
    vertexBuffer: u32,
    length: u32,
    shader_program: shader.Shader,

    pub fn clearColor(_: Renderer, color: Color) void {
        c.glClear(c.GL_COLOR_BUFFER_BIT);
        c.glClearColor(color.r, color.g, color.b, color.a);
    }

    pub fn useShader(self: *Renderer, shader_program: shader.Shader) void {
        self.shader_program = shader_program;
        c.glUseProgram(shader_program.program_id);
    }

    pub fn drawTriangles(self: *Renderer, vertices: []const f32) void {
        self.length = @intCast(vertices.len);

        c.glGenBuffers(1, &self.vertexBuffer);

        c.glGenVertexArrays(1, &self.vertexArray);
        c.glBindVertexArray(self.vertexArray);

        c.glBindBuffer(c.GL_ARRAY_BUFFER, self.vertexBuffer);
        c.glBufferData(c.GL_ARRAY_BUFFER, @intCast(vertices.len * @sizeOf(f32)), vertices.ptr, c.GL_STATIC_DRAW);

        c.glVertexAttribPointer(0, 3, c.GL_FLOAT, c.GL_FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
        c.glEnableVertexAttribArray(0);
    }

    pub fn useCamera(self: *Renderer, cam: camera.Camera) void {
        self.shader_program.uploadMat4("view", cam.getViewMatrix());
        self.shader_program.uploadMat4("projection", cam.getProjectionMatrix());
    }

    pub fn render(self: Renderer) void {
        c.glDrawArrays(c.GL_TRIANGLES, 0, @intCast(self.length / 3));
    }

    pub fn deinit(self: Renderer) void {
        c.glDeleteVertexArrays(1, &self.vertexArray);
        c.glDeleteBuffers(1, &self.vertexBuffer);
    }
};

pub fn create() Renderer {
    return Renderer{
        .vertexArray = 0,
        .vertexBuffer = 0,
        .length = 0,
        .shader_program = shader.Shader{ .program_id = 0 },
    };
}
