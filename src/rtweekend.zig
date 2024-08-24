const std = @import("std");

pub const infinity = std.math.floatMax(f64);
pub const pi = std.math.pi;

pub fn degreesToRadians(degrees: f64) f64 {
    return degrees * pi / 180.0;
}

pub fn randomDouble() !f64 {
    var seed: u64 = undefined;
    try std.posix.getrandom(std.mem.asBytes(&seed));
    var prng = std.Random.DefaultPrng.init(seed);
    return prng.random().float(f64);
}

pub fn randomDoubleRange(min: f64, max: f64) !f64 {
    return min + (max - min) * randomDouble();
}
