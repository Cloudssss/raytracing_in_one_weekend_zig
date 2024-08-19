pub const Point3 = @import("vec3.zig").Vec3;
pub const Vec3 = @import("vec3.zig").Vec3;
pub const vec = @import("vec3.zig").vec3;
const testing = @import("std").testing;

pub const Ray = struct {
    origin: Point3,
    direction: Vec3,

    const Self = @This();

    pub fn init(origin: Point3, direction: Vec3) Self {
        return .{
            .origin = origin,
            .direction = direction,
        };
    }

    pub fn at(self: Self, t: f64) Point3 {
        return self.origin.add(self.direction.multiplyNum(t));
    }
};

pub const ray = Ray.init;
pub const point3 = Point3.init;

test "Ray" {
    const p = point3(1, 1, 1);
    const d = vec(-0.5, -0.5, -0.5);
    const r = ray(p, d);

    const end = r.at(2);
    try testing.expect(end.approxEq(point3(0.0, 0.0, 0.0)));
}
