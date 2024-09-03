const std = @import("std");
const sqrt = std.math.sqrt;
const Vec3 = @import("vec3.zig").Vec3;

const vec3 = @import("vec3.zig").vec3;

const Color = @import("color.zig").Color;
const color = @import("color.zig").color;

const Ray = @import("ray.zig").Ray;
const ray = @import("ray.zig").ray;
const Point3 = @import("ray.zig").Point3;
const point3 = @import("ray.zig").point3;

const Hittable = @import("hittable.zig").Hittable;
const Sphere = @import("sphere.zig").Sphere;
const sphere = @import("sphere.zig").sphere;
const HitRecord = @import("hittable.zig").HitRecord;
const HittableList = @import("hittable_list.zig").HittableList;

const Interval = @import("interval.zig").Interval;
const interval = @import("interval.zig").interval;

const Camera = @import("camera.zig").Camera;

const Material = @import("material.zig").Material;
const Lambertian = @import("material.zig").Lambertian;
const Metal = @import("material.zig").Metal;
const Dielectric = @import("material.zig").Dielectric;

const infinity = @import("rtweekend.zig").infinity;
const pi = @import("rtweekend.zig").pi;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = HittableList.init(allocator);

    const material_ground = Material{ .lambertian = Lambertian.init(color(0.8, 0.8, 0.0)) };
    const material_center = Material{ .lambertian = Lambertian.init(color(0.1, 0.2, 0.5)) };
    const material_left = Material{ .dielectric = Dielectric.init(1.5) };
    const material_bubble = Material{ .dielectric = Dielectric.init(1.0 / 1.5) };
    const material_right = Material{ .metal = Metal.init(color(0.8, 0.6, 0.2), 1.0) };

    try world.add(.{ .sphere = sphere(point3(0, -100.5, -1), 100, &material_ground) });
    try world.add(.{ .sphere = sphere(point3(0, 0, -1.2), 0.5, &material_center) });
    try world.add(.{ .sphere = sphere(point3(-1, 0, -1), 0.5, &material_left) });
    try world.add(.{ .sphere = sphere(point3(-1.0, 0.0, -1.0), 0.4, &material_bubble) });
    try world.add(.{ .sphere = sphere(point3(1, 0, -1), 0.5, &material_right) });
    defer world.deinit();

    var cam = Camera.init();

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = point3(-2, 2, 1);
    cam.lookat = point3(0, 0, -1);
    cam.vup = vec3(0, 1, 0);

    cam.defocus_angle = 10.0;
    cam.focus_dist = 3.4;

    try cam.render(world);
}
