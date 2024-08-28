const std = @import("std");
const Hittable = @import("hittable.zig").Hittable;
const Vec3 = @import("vec3.zig").Vec3;
const vec3 = @import("vec3.zig").vec3;
const Point3 = @import("ray.zig").Point3;
const point3 = @import("ray.zig").point3;
const Color = @import("color.zig").Color;
const color = @import("color.zig").color;
const printColor = @import("color.zig").printColor;
const Ray = @import("ray.zig").Ray;
const ray = @import("ray.zig").ray;
const HitRecord = @import("hittable.zig").HitRecord;
const HittableList = @import("hittable_list.zig").HittableList;
const Interval = @import("interval.zig").Interval;
const interval = @import("interval.zig").interval;
const infinity = @import("rtweekend.zig").infinity;
const randomDouble = @import("rtweekend.zig").randomDouble;

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: u32 = 100,
    samples_per_pixel: u32 = 10,
    max_depth: u32 = 10,

    image_height: u32,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    const Self = @This();

    pub fn render(self: *Self, world: HittableList) !void {
        self.initialize();

        const stdout = std.io.getStdOut().writer();
        try stdout.print("P3\n{d} {d}\n255\n", .{ self.image_width, self.image_height });

        var buffered = std.io.bufferedWriter(std.io.getStdErr().writer());
        const bw = buffered.writer();

        for (0..self.image_height) |j| {
            try bw.print("\rScanlines remaining: {d} ", .{self.image_height - j});
            try buffered.flush();
            for (0..self.image_width) |i| {
                var pixel_color = color(0, 0, 0);
                for (0..self.samples_per_pixel) |_| {
                    const r = self.getRay(@intCast(i), @intCast(j));
                    pixel_color.addAssign(self.rayColor(r, self.max_depth, world));
                }
                try printColor(stdout, pixel_color, self.samples_per_pixel);
            }
        }

        try bw.print("\rDone.                 \n", .{});
        try buffered.flush();
    }

    pub fn init() Self {
        return undefined;
    }

    fn initialize(self: *Self) void {
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / self.aspect_ratio);
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.center = point3(0, 0, 0);

        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        const viewport_u = vec3(viewport_width, 0, 0);
        const viewport_v = vec3(0, -viewport_height, 0);
        self.pixel_delta_u = viewport_u.dividedByNum(@floatFromInt(self.image_width));
        self.pixel_delta_v = viewport_v.dividedByNum(@floatFromInt(self.image_height));

        const viewport_upper_left = self.center.sub(vec3(0, 0, focal_length)).sub(viewport_u.dividedByNum(2)).sub(viewport_v.dividedByNum(2));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).multiplyNum(0.5));
    }

    fn getRay(self: Self, i: u32, j: u32) Ray {
        const i_f: f64 = @floatFromInt(i);
        const j_f: f64 = @floatFromInt(j);
        const pixel_center = self.pixel00_loc.add(self.pixel_delta_u.multiplyNum(i_f)).add(self.pixel_delta_v.multiplyNum(j_f));
        const pixel_sample = pixel_center.add(self.pixelSampleSquare());

        const ray_origin = self.center;
        const ray_direction = pixel_sample.sub(self.center);

        return ray(ray_origin, ray_direction);
    }

    fn pixelSampleSquare(self: Self) Vec3 {
        const px = -0.5 + randomDouble();
        const py = -0.5 + randomDouble();
        return self.pixel_delta_u.multiplyNum(px).add(self.pixel_delta_v.multiplyNum(py));
    }

    fn rayColor(self: Self, r: Ray, depth: u32, world: HittableList) Color {
        var rec: HitRecord = undefined;

        if (depth <= 0)
            return color(0, 0, 0);

        if (world.hit(r, interval(0.001, infinity), &rec)) {
            const direction = rec.normal.add(Vec3.randomUnitVector());
            return self.rayColor(ray(rec.p, direction), depth - 1, world).multiplyNum(0.5);
        }

        const unit_direction = r.direction.unitVector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        return color(1, 1, 1).multiplyNum(1.0 - a).add(color(0.5, 0.7, 1.0).multiplyNum(a));
    }
};
