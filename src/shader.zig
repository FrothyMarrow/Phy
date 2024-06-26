const std = @import("std");

const c = @cImport({
    @cInclude("OpenGL/gl3.h");
});

pub const Shader = struct {
    program_id: u32,

    pub fn uploadMat4(self: *Shader, name: []const u8, value: [16]f32) void {
        const location = c.glGetUniformLocation(self.program_id, @ptrCast(name));
        c.glUniformMatrix4fv(location, 1, c.GL_FALSE, @ptrCast(&value));
    }

    pub fn deinit(self: Shader) void {
        c.glDeleteProgram(self.program_id);
    }
};

pub const ShaderError = error{
    ShaderAllocationError,
    ShaderFileNotOpenedError,
    ShaderFileNotReadError,
    ShaderFileStatError,
    ShaderCompilationError,
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
    defer {
        if (gpa.deinit() != .ok) {
            std.debug.panic(
                "Allocator check for {} failed, leaked memory at {s}\n",
                .{ @TypeOf(gpa), @src().fn_name },
            );
        }
    }

    const buffer = allocator.alloc(u8, stat.size + 1) catch {
        std.debug.print("Failed to allocate buffer for file: {s}\n", .{path});
        return ShaderError.ShaderAllocationError;
    };
    buffer[buffer.len - 1] = 0;
    defer allocator.free(buffer);

    const read = file.reader().readAll(buffer) catch {
        std.debug.print("Failed to read file: {s}\n", .{path});
        return ShaderError.ShaderFileNotReadError;
    };

    if (read != stat.size) {
        std.debug.print("Failed to read file: {s}\n", .{path});
        return ShaderError.ShaderFileNotReadError;
    }

    const shader = c.glCreateShader(shader_type);
    c.glShaderSource(shader, 1, @ptrCast(&buffer), null);
    c.glCompileShader(shader);

    var success: i32 = 0;
    var infoLog = std.mem.zeroes([512]u8);

    c.glGetShaderiv(shader, c.GL_COMPILE_STATUS, &success);

    if (success == 0) {
        c.glGetShaderInfoLog(shader, 512, null, &infoLog);
        std.debug.print("Shader compilation failed: {s}\n", .{infoLog});
        return ShaderError.ShaderCompilationError;
    }

    return shader;
}
