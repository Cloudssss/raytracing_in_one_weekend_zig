const Ray = @import("ray.zig").Ray;
const ray = @import("ray.zig").ray;
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,

    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        switch (self) {
            inline else => |h| return h.scatter(r_in, rec, attenuation, scattered),
        }
    }
};

pub const Lambertian = struct {
    albedo: Color,

    const Self = @This();

    pub fn init(c: Color) Self {
        return .{
            .albedo = c,
        };
    }

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = r_in;
        var scatter_direction = rec.normal.add(Vec3.randomUnitVector());
        if (scatter_direction.nearZero())
            scatter_direction = rec.normal;
        scattered.* = ray(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Metal = struct {
    albedo: Color,
    fuzz: f64,

    const Self = @This();

    pub fn init(a: Color, f: f64) Self {
        return .{
            .albedo = a,
            .fuzz = if (f < 1) f else 1,
        };
    }

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        const reflected = Vec3.reflect(r_in.direction.unitVector(), rec.normal);
        scattered.* = ray(rec.p, reflected.add(Vec3.randomUnitVector().multiplyNum(self.fuzz)));
        attenuation.* = self.albedo;
        return scattered.direction.dot(rec.normal) > 0;
    }
};
