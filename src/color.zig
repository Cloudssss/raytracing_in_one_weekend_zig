const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const interval = @import("interval.zig").interval;

pub const Color = Vec3;

pub fn printColor(co: Color, samples_per_pixel: u32) !void {
    var r = co.x();
    var g = co.y();
    var b = co.z();

    const scale = 1.0 / @as(f64, @floatFromInt(samples_per_pixel));
    r *= scale;
    g *= scale;
    b *= scale;

    const intensity = interval(0.000, 0.999);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}\n", .{
        @as(u32, @intFromFloat(intensity.clamp(r) * 256)),
        @as(u32, @intFromFloat(intensity.clamp(g) * 256)),
        @as(u32, @intFromFloat(intensity.clamp(b) * 256)),
    });
}

pub fn color(r: f64, g: f64, b: f64) Color {
    return Color.init(r, g, b);
}
