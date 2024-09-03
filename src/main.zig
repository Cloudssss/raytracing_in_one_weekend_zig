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

const randomDouble = @import("rtweekend.zig").randomDouble;
const randomDoubleRange = @import("rtweekend.zig").randomDoubleRange;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = HittableList.init(allocator);

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();
    const arena_allocator = arena.allocator();

    const ground_material = try arena_allocator.create(Material);
    ground_material.* = .{ .lambertian = Lambertian.init(color(0.5, 0.5, 0.5)) };
    try world.add(.{ .sphere = sphere(point3(0, -100.5, -1), 100, ground_material) });
    defer world.deinit();

    var a: i32 = -11;
    var b: i32 = -11;
    while (a < 11) : (a += 1) {
        while (b < 11) : (b += 1) {
            const choose_mat = randomDouble();
            const center = point3(@as(f64, @floatFromInt(a)) + 0.9 * randomDouble(), 0.2, @as(f64, @floatFromInt(b)) + 0.9 * randomDouble());

            if (center.sub(point3(4, 0.2, 0)).length() > 0.9) {
                const sphere_material = try arena_allocator.create(Material);
                if (choose_mat < 0.8) {
                    const albedo = Color.random().multiply(Color.random());
                    sphere_material.* = .{ .lambertian = Lambertian.init(albedo) };
                    try world.add(.{ .sphere = sphere(center, 0.2, sphere_material) });
                } else if (choose_mat < 0.95) {
                    const albedo = Color.randomRange(0.5, 1);
                    const fuzz = randomDoubleRange(0, 0.5);
                    sphere_material.* = .{ .metal = Metal.init(albedo, fuzz) };
                    try world.add(.{ .sphere = sphere(center, 0.2, sphere_material) });
                } else {
                    sphere_material.* = .{ .dielectric = Dielectric.init(1.5) };
                    try world.add(.{ .sphere = sphere(center, 0.2, sphere_material) });
                }
            }
        }
    }

    const material1 = try arena_allocator.create(Material);
    material1.* = .{ .dielectric = Dielectric.init(1.5) };
    try world.add(.{ .sphere = sphere(point3(0, 1, 0), 0.2, material1) });

    const material2 = try arena_allocator.create(Material);
    material2.* = .{ .lambertian = Lambertian.init(color(0.4, 0.2, 0.1)) };
    try world.add(.{ .sphere = sphere(point3(-4, 1, 0), 0.2, material2) });

    const material3 = try arena_allocator.create(Material);
    material3.* = .{ .metal = Metal.init(color(0.7, 0.6, 0.5), 0.0) };
    try world.add(.{ .sphere = sphere(point3(4, 1, 0), 0.2, material3) });

    var cam = Camera.init();

    cam.aspect_ratio = 16.0 / 9.0;
    cam.image_width = 1200;
    cam.samples_per_pixel = 500;
    cam.max_depth = 50;

    cam.vfov = 20;
    cam.lookfrom = point3(13, 2, 3);
    cam.lookat = point3(0, 0, 0);
    cam.vup = vec3(0, 1, 0);

    cam.defocus_angle = 0.6;
    cam.focus_dist = 10.0;

    try cam.render(world);
}
