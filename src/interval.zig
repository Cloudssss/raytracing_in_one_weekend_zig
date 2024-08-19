const std = @import("std");

pub const Interval = struct {
    min: f64,
    max: f64,

    const Self = @This();

    pub fn init(m: f64, n: f64) Self {
        return .{
            .min = m,
            .max = n,
        };
    }

    pub fn default() Self {
        return .{
            .min = std.math.floatMax(f64),
            .max = std.math.floatMin(f64),
        };
    }

    pub fn contains(self: Self, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: Self, x: f64) bool {
        return self.min < x and x < self.max;
    }
};

pub const empty = Interval{
    .min = std.math.floatMax(f64),
    .max = std.math.floatMin(f64),
};

pub const universe = Interval{
    .min = std.math.floatMin(f64),
    .max = std.math.floatMax(f64),
};

pub const interval = Interval.init;
