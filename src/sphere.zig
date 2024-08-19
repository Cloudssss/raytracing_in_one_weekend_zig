const Point3 = @import("ray.zig").Point3;
const Ray = @import("ray.zig").Ray;
const Vec3 = @import("vec3.zig").Vec3;
const HitRecord = @import("hittable.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
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

    pub fn hit(self: Self, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        const oc = r.origin.sub(self.center);
        const a = r.direction.lengthSquared();
        const half_b = oc.dot(r.direction);
        const c = oc.lengthSquared() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;
        if (discriminant < 0) return false;
        const sqrtd = sqrt(discriminant);

        var root = (-half_b - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (-half_b + sqrtd) / a;
            if (!ray_t.surrounds(root))
                return false;
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = rec.p.sub(self.center).dividedByNum(self.radius);
        rec.setFaceNormal(r, outward_normal);

        return true;
    }
};

pub const sphere = Sphere.init;
