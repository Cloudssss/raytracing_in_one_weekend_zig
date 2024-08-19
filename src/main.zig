const std = @import("std");
const Vec3 = @import("vec3.zig").Vec3;

const vec3 = @import("vec3.zig").vec3;
const color = @import("color.zig").color;
const Color = @import("color.zig").Color;
const printColor = @import("color.zig").printColor;

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
        try bw.print("\rScanlines remaining: {d} ", .{image_size.height - j});
        try buffered.flush();
        for (0..image_size.width) |i| {
            const pixel_color: Color = color(
                @as(f64, @floatFromInt(i)) / (image_size.width - 1),
                @as(f64, @floatFromInt(j)) / (image_size.height - 1),
                0,
            );
            try printColor(pixel_color);
        }
    }

    try bw.print("\rDone.                 \n", .{});
    try buffered.flush();
}

const ImageSize = struct {
    width: u32,
    height: u32,
};
