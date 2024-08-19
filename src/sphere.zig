const Point3 = @import("ray.zig").Point3;
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("vec3.zig").Vec3;
const HitRecord = @import("hittable.zig").HitRecord;
const sqrt = @import("std").math.sqrt;

pub const Sphere = struct {
    center: Point3,
    radius: f64,

    const Self = @This();
    pub fn init(p: Point3, r: f64) Self {
        return .{
            .center = p,
            .radius = r,
        };
    }

    pub fn hit(self: Self, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        const oc = r.origin.sub(self.center);
        const a = r.direction.lengthSquared();
        const half_b = oc.dot(r.direction);
        const c = oc.lengthSquared() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false;
        const sqrtd = sqrt(discriminant);

        var root = (-half_b - sqrtd) / a;
        if (root <= ray_tmin or ray_tmax <= root) {
            root = (-half_b + sqrtd) / a;
            if (root <= ray_tmin or ray_tmax <= root)
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        rec.normal = (rec.p - self.center) / self.radius;

        return true;
    }
};

pub const sphere = Sphere.init;
