const std = @import("std");

pub const Vector3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn add(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.x - other.x,
            .y = self.y - other.y,
            .z = self.z - other.z,
        };
    }

    pub fn cross(self: Vector3, other: Vector3) Vector3 {
        return Vector3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn dot(self: Vector3, other: Vector3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn normalize(self: Vector3) Vector3 {
        const length = std.math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
        return Vector3{
            .x = self.x / length,
            .y = self.y / length,
            .z = self.z / length,
        };
    }
};

pub fn create() Vector3 {
    return Vector3{
        .x = 0.0,
        .y = 0.0,
        .z = 0.0,
    };
}
