const std = @import("std");
const sqrt = std.math.sqrt;
const Vec3 = @import("vec3.zig").Vec3;

const vec3 = @import("vec3.zig").vec3;

const Color = @import("color.zig").Color;
const color = @import("color.zig").color;
const printColor = @import("color.zig").printColor;

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

const infinity = @import("rtweekend.zig").infinity;
const pi = @import("rtweekend.zig").pi;

pub fn main() !void {
    const aspect_ration = 16.0 / 9.0;
    const image_width: u32 = 400;
    var image_height: u32 = @as(f64, @floatFromInt(image_width)) / aspect_ration;
    image_height = if (image_height < 1) 1 else image_height;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var world = HittableList.init(allocator);
    defer world.deinit();

    try world.add(.{ .sphere = sphere(point3(0, 0, -1), 0.5) });
    try world.add(.{ .sphere = sphere(point3(0, -100.5, -1), 100) });

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / @as(f64, @floatFromInt(image_height)));
    const camera_center = point3(0, 0, 0);

    const viewport_u = vec3(viewport_width, 0, 0);
    const viewport_v = vec3(0, -viewport_height, 0);
    const pixel_delta_u = viewport_u.dividedByNum(image_width);
    const pixel_delta_v = viewport_v.dividedByNum(@floatFromInt(image_height));

    const viewport_upper_left = camera_center.sub(vec3(0, 0, focal_length)).sub(viewport_u.dividedByNum(2)).sub(viewport_v.dividedByNum(2));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).multiplyNum(0.5));

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    var buffered = std.io.bufferedWriter(std.io.getStdErr().writer());
    const bw = buffered.writer();

    for (0..image_height) |j| {
        try bw.print("\rScanlines remaining: {d} ", .{image_height - j});
        try buffered.flush();
        for (0..image_width) |i| {
            const i_f: f64 = @floatFromInt(i);
            const j_f: f64 = @floatFromInt(j);
            const pixel_center = pixel00_loc.add(pixel_delta_u.multiplyNum(i_f)).add(pixel_delta_v.multiplyNum(j_f));
            const ray_direction = pixel_center.sub(camera_center);
            const r = ray(camera_center, ray_direction);
            const pixel_color = rayColor(r, world);
            try printColor(pixel_color);
        }
    }

    try bw.print("\rDone.                 \n", .{});
    try buffered.flush();
}

pub fn hitSphere(center: Point3, radius: f64, r: Ray) f64 {
    const oc = r.origin.sub(center);
    const a = r.direction.dot(r.direction);
    const half_b = oc.dot(r.direction);
    const c = oc.dot(oc) - radius * radius;
    const discriminant = half_b * half_b - a * c;
    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-half_b - sqrt(discriminant)) / a;
    }
}

pub fn rayColor(r: Ray, world: HittableList) Color {
    var rec: HitRecord = undefined;
    if (world.hit(r, interval(0, infinity), &rec)) {
        return rec.normal.add(color(1, 1, 1)).multiplyNum(0.5);
    }
    const unit_direction = r.direction.unitVector();
    const a = 0.5 * (unit_direction.y() + 1.0);
    return color(1, 1, 1).multiplyNum(1.0 - a).add(color(0.5, 0.7, 1.0).multiplyNum(a));
}
