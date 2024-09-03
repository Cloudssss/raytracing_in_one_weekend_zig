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
const degreesToRadians = @import("rtweekend.zig").degreesToRadians;

pub const Camera = struct {
    aspect_ratio: f64 = 1.0,
    image_width: u32 = 100,
    samples_per_pixel: u32 = 10,
    max_depth: u32 = 10,

    vfov: f64 = 90,
    lookfrom: Point3 = point3(0, 0, 0),
    lookat: Point3 = point3(0, 0, -1),
    vup: Vec3 = vec3(0, 1, 0),

    defocus_angle: f64 = 0,
    focus_dist: f64 = 10,

    image_height: u32,
    center: Point3,
    pixel00_loc: Point3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    defocus_disk_u: Vec3,
    defocus_disk_v: Vec3,

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

        self.center = self.lookfrom;

        const theta = degreesToRadians(self.vfov);
        const h = std.math.tan(theta / 2);
        const viewport_height = 2.0 * h * self.focus_dist;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        self.w = self.lookfrom.sub(self.lookat).unitVector();
        self.u = self.vup.cross(self.w).unitVector();
        self.v = self.w.cross(self.u);

        const viewport_u = self.u.multiplyNum(viewport_width);
        const viewport_v = self.v.negative().multiplyNum(viewport_height);

        self.pixel_delta_u = viewport_u.dividedByNum(@floatFromInt(self.image_width));
        self.pixel_delta_v = viewport_v.dividedByNum(@floatFromInt(self.image_height));

        const viewport_upper_left = self.center
            .sub(self.w.multiplyNum(self.focus_dist))
            .sub(viewport_u.dividedByNum(2))
            .sub(viewport_v.dividedByNum(2));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).multiplyNum(0.5));

        const defocus_radius = self.focus_dist * std.math.tan(degreesToRadians(self.defocus_angle / 2));
        self.defocus_disk_u = self.u.multiplyNum(defocus_radius);
        self.defocus_disk_v = self.v.multiplyNum(defocus_radius);
    }

    fn getRay(self: Self, i: u32, j: u32) Ray {
        const i_f: f64 = @floatFromInt(i);
        const j_f: f64 = @floatFromInt(j);
        const pixel_center = self.pixel00_loc.add(self.pixel_delta_u.multiplyNum(i_f)).add(self.pixel_delta_v.multiplyNum(j_f));
        const pixel_sample = pixel_center.add(self.pixelSampleSquare());

        const ray_origin = if (self.defocus_angle <= 0) self.center else self.defocusDiskSample();
        const ray_direction = pixel_sample.sub(ray_origin);

        return ray(ray_origin, ray_direction);
    }

    fn pixelSampleSquare(self: Self) Vec3 {
        const px = -0.5 + randomDouble();
        const py = -0.5 + randomDouble();
        return self.pixel_delta_u.multiplyNum(px).add(self.pixel_delta_v.multiplyNum(py));
    }

    fn defocusDiskSample(self: Self) Point3 {
        const p = Vec3.randomInUnitDisk();
        return self.center.add(self.defocus_disk_u.multiplyNum(p.x())).add(self.defocus_disk_v.multiplyNum(p.y()));
    }

    fn rayColor(self: Self, r: Ray, depth: u32, world: HittableList) Color {
        var rec: HitRecord = undefined;

        if (depth <= 0)
            return color(0, 0, 0);

        if (world.hit(r, interval(0.001, infinity), &rec)) {
            var scattered: Ray = undefined;
            var attenuation: Color = undefined;
            if (rec.mat.scatter(r, rec, &attenuation, &scattered))
                return attenuation.multiply(self.rayColor(scattered, depth - 1, world));
            return color(0, 0, 0);
        }

        const unit_direction = r.direction.unitVector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        return color(1, 1, 1).multiplyNum(1.0 - a).add(color(0.5, 0.7, 1.0).multiplyNum(a));
    }
};
