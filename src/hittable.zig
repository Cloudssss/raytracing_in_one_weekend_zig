const Ray = @import("ray.zig").Ray;
const Point3 = @import("ray.zig").Point3;
const Vec3 = @import("vec3.zig").Vec3;
const Sphere = @import("sphere.zig").Sphere;

const Hittable = union(enum) {
    sphere: *Sphere,

    const Self = @This();

    pub fn hit(self: Self, r: Ray, ray_tmin: f64, ray_tmax: f64, rec: *HitRecord) bool {
        switch (self) {
            inline else => |h| h.hit(r, ray_tmin, ray_tmax, rec),
        }
    }
};

const HitRecord = struct {
    p: Point3,
    normal: Vec3,
    t: f64,
};
