const Ray = @import("ray.zig").Ray;
const ray = @import("ray.zig").ray;
const HitRecord = @import("hittable.zig").HitRecord;
const Color = @import("color.zig").Color;
const color = @import("color.zig").color;
const Vec3 = @import("vec3.zig").Vec3;
const fmin = @import("rtweekend.zig").fmin;
const fabs = @import("rtweekend.zig").fabs;
const math = @import("std").math;
const randomDouble = @import("rtweekend.zig").randomDouble;

pub const Material = union(enum) {
    lambertian: Lambertian,
    metal: Metal,
    dielectric: Dielectric,

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

pub const Dielectric = struct {
    ir: f64,

    const Self = @This();

    pub fn init(index_of_refrection: f64) Self {
        return .{
            .ir = index_of_refrection,
        };
    }

    fn reflectance(cosine: f64, refraction_index: f64) f64 {
        const r0 = (1 - refraction_index) / (1 + refraction_index);
        const r = r0 * r0;
        return r + (1 - r) * math.pow(f64, 1 - cosine, 5);
    }

    pub fn scatter(self: Self, r_in: Ray, rec: HitRecord, attenuation: *Color, scattered: *Ray) bool {
        attenuation.* = color(1.0, 1.0, 1.0);
        const ri = if (rec.front_face) (1.0 / self.ir) else self.ir;

        const unit_direction = r_in.direction.unitVector();
        const cos_theta = fmin(unit_direction.negative().dot(rec.normal), 1.0);
        const sin_theta = math.sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = ri * sin_theta > 1.0;
        var direction: Vec3 = undefined;

        if (cannot_refract or reflectance(cos_theta, ri) > randomDouble()) {
            direction = Vec3.reflect(unit_direction, rec.normal);
        } else {
            direction = Vec3.refract(unit_direction, rec.normal, ri);
        }

        scattered.* = ray(rec.p, direction);
        return true;
    }
};
