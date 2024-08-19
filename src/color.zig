const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

pub const Color = Vec3;

pub fn printColor(co: Color) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}\n", .{
        @as(u32, @intFromFloat(co.x() * 255.999)),
        @as(u32, @intFromFloat(co.y() * 255.999)),
        @as(u32, @intFromFloat(co.z() * 255.999)),
    });
}

pub fn color(r: f64, g: f64, b: f64) Color {
    return Color.init(r, g, b);
}
