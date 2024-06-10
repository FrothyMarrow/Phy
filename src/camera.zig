const std = @import("std");
const vec = @import("math/vector3.zig");

pub const CameraSpec = struct {
    from: vec.Vector3,
    to: vec.Vector3,
    up: vec.Vector3,
};

pub const Camera = struct {
    viewMatrix: [16]f32,
    projectionMatrix: [16]f32,

    pub fn getViewMatrix(self: Camera) [16]f32 {
        return self.viewMatrix;
    }

    pub fn getProjectionMatrix(self: Camera) [16]f32 {
        return self.projectionMatrix;
    }

    pub fn createPerspective(self: *Camera, fov: f32, aspect: f32, near: f32, far: f32) void {
        const tangent = std.math.tan(fov / 2.0 * (std.math.pi / 180.0));
        const top = near * tangent;
        const right = top * aspect;

        self.projectionMatrix[0] = near / right;
        self.projectionMatrix[5] = near / top;
        self.projectionMatrix[10] = -(far + near) / (far - near);
        self.projectionMatrix[11] = -1.0;
        self.projectionMatrix[14] = -(2.0 * far * near) / (far - near);
        self.projectionMatrix[15] = 0.0;
    }
};

pub fn create(spec: CameraSpec) Camera {
    var forward = vec.create();
    var left = vec.create();
    var actualUp = vec.create();
    var viewMatrix = [_]f32{0.0} ** 16;

    forward = vec.Vector3.sub(spec.from, spec.to);
    forward = vec.Vector3.normalize(forward);

    left = vec.Vector3.cross(spec.up, forward);
    left = vec.Vector3.normalize(left);

    actualUp = vec.Vector3.cross(forward, left);
    viewMatrix[0] = left.x;
    viewMatrix[4] = left.y;
    viewMatrix[8] = left.z;
    viewMatrix[1] = spec.up.x;
    viewMatrix[5] = spec.up.y;
    viewMatrix[9] = spec.up.z;
    viewMatrix[2] = forward.x;
    viewMatrix[6] = forward.y;
    viewMatrix[10] = forward.z;

    viewMatrix[12] = -vec.Vector3.dot(left, spec.from);
    viewMatrix[13] = -vec.Vector3.dot(actualUp, spec.from);
    viewMatrix[14] = -vec.Vector3.dot(forward, spec.from);
    viewMatrix[15] = 1.0;

    return Camera{
        .viewMatrix = viewMatrix,
        .projectionMatrix = [_]f32{0.0} ** 16,
    };
}
