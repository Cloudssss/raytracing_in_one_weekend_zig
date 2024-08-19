const math = @import("std").math;

pub const Vec3 = struct {
    e: [3]f64,

    const Self = @This();

    pub fn zero() Self {
        return new(0, 0, 0);
    }

    pub fn new(e0: f64, e1: f64, e2: f64) Self {
        return .{
            .e = .{ e0, e1, e2 },
        };
    }

    pub fn x(self: Self) f64 {
        return self.e[0];
    }

    pub fn y(self: Self) f64 {
        return self.e[1];
    }

    pub fn z(self: Self) f64 {
        return self.e[2];
    }

    pub fn at(self: Self, index: i32) f64 {
        return self.e[index];
    }

    pub fn negative(self: Self) Self {
        return vec3(-self.e[0], -self.e[1], -self.e[2]);
    }

    pub fn add(a: Self, b: Self) Self {
        return vec3(a.x() + b.x(), a.y() + b.y(), a.y() + b.y());
    }

    pub fn addAssign(a: *Self, b: Self) *Self {
        a.e[0] += b.e[0];
        a.e[1] += b.e[1];
        a.e[2] += b.e[2];
        return a;
    }

    pub fn sub(a: Self, b: Self) Self {
        return vec3(a.x() - b.x(), a.y() - b.y(), a.y() - b.y());
    }

    pub fn subAssign(a: *Self, b: Self) *Self {
        a.e[0] -= b.e[0];
        a.e[1] -= b.e[1];
        a.e[2] -= b.e[2];
        return a;
    }

    pub fn multiplyAssign(a: *Self, t: f64) *Self {
        a.e[0] *= t;
        a.e[1] *= t;
        a.e[2] *= t;
        return a;
    }

    pub fn dividedByAssign(a: *Self, t: f64) *Self {
        return a.multiplyAssign(1 / t);
    }

    pub fn length(self: Self) f64 {
        return math.sqrt(self.lengthSquared());
    }

    pub fn lengthSquared(self: Self) f64 {
        return self.e[0] * self.e[0] + self.e[1] * self.e[1] + self.e[2] * self.e[2];
    }
};

pub const vec3 = Vec3.new;
