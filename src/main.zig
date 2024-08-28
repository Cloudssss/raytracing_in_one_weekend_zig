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

const infinity = @import("rtweekend.zig").infinity;
const pi = @import("rtweekend.zig").pi;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = HittableList.init(allocator);
    defer world.deinit();

    try world.add(.{ .sphere = sphere(point3(0, 0, -1), 0.5) });
    try world.add(.{ .sphere = sphere(point3(0, -100.5, -1), 100) });

    var cam = Camera.init();
    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 400;
    cam.samples_per_pixel = 100;
    cam.max_depth = 50;
    try cam.render(world);
}
