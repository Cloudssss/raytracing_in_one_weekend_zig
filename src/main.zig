const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;
const vec3 = @import("vec3.zig").vec3;

pub fn main() !void {
    const image_size = ImageSize{
        .width = 256,
        .height = 256,
    };

    const stdout = std.io.getStdOut().writer();
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_size.width, image_size.height });

    var buffered = std.io.bufferedWriter(std.io.getStdErr().writer());
    const bw = buffered.writer();

    for (0..image_size.height) |j| {
        for (0..image_size.width) |i| {
            try bw.print("\rScanlines remaining: {d} ", .{image_size.height - j});
            try buffered.flush();
            const r = @as(f32, @floatFromInt(i)) / (image_size.width - 1);
            const g = @as(f32, @floatFromInt(j)) / (image_size.height - 1);
            const b: f32 = 0;

            const ir = @as(u32, @intFromFloat(255.99 * r));
            const ig = @as(u32, @intFromFloat(255.99 * g));
            const ib = @as(u32, @intFromFloat(255.99 * b));
            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }

    try bw.print("\rDone.                 \n", .{});
    try buffered.flush();
}

const ImageSize = struct {
    width: u32,
    height: u32,
};
