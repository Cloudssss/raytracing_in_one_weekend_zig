const std = @import("std");

pub const infinity = std.math.floatMax(f64);
pub const pi = std.math.pi;

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}