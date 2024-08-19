pub const Point3 = @import("vec3.zig").Vec3;
pub const Vec3 = @import("vec3.zig").Vec3;

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
        return self.origin + t * self.direction;
    }
};

pub const ray = Ray.init;
pub const point3 = Point3.new;
