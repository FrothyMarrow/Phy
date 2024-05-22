const std = @import("std");

const c = @cImport({
    @cInclude("OpenGL/gl3.h");
});

pub const Shader = struct {
    program_id: u32,

    pub fn deinit(self: Shader) void {
        c.glDeleteProgram(self.program_id);
    }
};

pub const ShaderError = error{
    ShaderAllocationError,
    ShaderFileNotOpenedError,
    ShaderFileNotReadError,
    ShaderFileStatError,
};

pub fn create(vertex_source: []const u8, fragment_source: []const u8) ShaderError!Shader {
    const vertex_shader = try createGLShader(vertex_source, c.GL_VERTEX_SHADER);
    const fragment_shader = try createGLShader(fragment_source, c.GL_FRAGMENT_SHADER);

    const shader_program = c.glCreateProgram();
    c.glAttachShader(shader_program, vertex_shader);
    c.glAttachShader(shader_program, fragment_shader);
    c.glLinkProgram(shader_program);

    c.glDeleteShader(vertex_shader);
    c.glDeleteShader(fragment_shader);

    return Shader{ .program_id = shader_program };
}

fn createGLShader(path: []const u8, shader_type: u32) ShaderError!u32 {
    const dir = std.fs.cwd();
    const file = dir.openFile(path, .{
        .mode = .read_only,
    }) catch {
        std.debug.print("Failed to open file: {s}\n", .{path});
        return ShaderError.ShaderFileNotOpenedError;
    };
    const stat = file.stat() catch {
        std.debug.print("Failed to stat file: {s}\n", .{path});
        return ShaderError.ShaderFileStatError;
    };
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer if (gpa.deinit() != .ok) {
        std.debug.panic(
            "Allocator check for {} failed, leaked memory at {s}\n",
            .{ @TypeOf(gpa), @src().fn_name },
        );
    };

    const buffer = allocator.alloc(u8, stat.size) catch {
        std.debug.print("Failed to allocate buffer for file: {s}\n", .{path});
        return ShaderError.ShaderAllocationError;
    };
    defer allocator.free(buffer);

    file.reader().readNoEof(buffer) catch {
        std.debug.print("Failed to read file: {s}\n", .{path});
        return ShaderError.ShaderFileNotReadError;
    };

    const shader = c.glCreateShader(shader_type);
    c.glShaderSource(shader, 1, @ptrCast(&buffer), null);
    c.glCompileShader(shader);

    return shader;
}
