const Ray = @import("ray.zig").Ray;
const ray = @import("ray.zig").ray;
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;
const Vec3 = @import("vec3.zig").Vec3;

const Material = union(enum) {
    const Self = @This();

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        switch (self) {
            inline else => |h| return h.scatter(r_in, rec, attenuation, scattered),
        }
    }
};

const Lambertian = struct {
    albedo: Color,

    const Self = @This();

    pub fn init(c: Color) Self {
        return .{
            .albedo = c,
        };
    }

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        _ = r_in;
        const scatter_direction = rec.normal.add(Vec3.randomUnitVector());
        scattered.* = ray(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};
