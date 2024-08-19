const std = @import("std");
const math = std.math;
const testing = std.testing;

pub const Vec3 = struct {
    e: [3]f64,

    const Self = @This();

    pub fn zero() Self {
        return init(0, 0, 0);
    }

    pub fn init(e0: f64, e1: f64, e2: f64) Self {
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

    pub fn at(self: Self, index: usize) f64 {
        return self.e[index];
    }

    pub fn negative(self: Self) Self {
        return vec3(-self.e[0], -self.e[1], -self.e[2]);
    }

    pub fn add(a: Self, b: Self) Self {
        return vec3(a.e[0] + b.e[0], a.e[1] + b.e[1], a.e[2] + b.e[2]);
    }

    pub fn addAssign(a: *Self, b: Self) *Self {
        a.e[0] += b.e[0];
        a.e[1] += b.e[1];
        a.e[2] += b.e[2];
        return a;
    }

    pub fn sub(a: Self, b: Self) Self {
        return vec3(a.e[0] - b.e[0], a.e[1] - b.e[1], a.e[2] - b.e[2]);
    }

    pub fn subAssign(a: *Self, b: Self) *Self {
        a.e[0] -= b.e[0];
        a.e[1] -= b.e[1];
        a.e[2] -= b.e[2];
        return a;
    }

    pub fn multiply(a: Self, b: Self) Self {
        return vec3(a.e[0] * b.e[0], a.e[1] * b.e[1], a.e[2] * b.e[2]);
    }

    pub fn multiplyNum(a: Self, b: f64) Self {
        return vec3(a.e[0] * b, a.e[1] * b, a.e[2] * b);
    }

    pub fn multiplyAssign(a: *Self, t: f64) *Self {
        a.e[0] *= t;
        a.e[1] *= t;
        a.e[2] *= t;
        return a;
    }

    pub fn dividedByNum(a: Self, b: f64) Self {
        return vec3(a.e[0] * (1 / b), a.e[1] * (1 / b), a.e[2] * (1 / b));
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

    pub fn dot(a: Self, b: Self) f64 {
        return a.e[0] * b.e[0] + a.e[1] * b.e[1] + a.e[2] * b.e[2];
    }

    pub fn cross(u: Self, v: Self) Self {
        return vec3(
            u.e[1] * v.e[2] - u.e[2] * v.e[1],
            u.e[2] * v.e[0] - u.e[0] * v.e[2],
            u.e[0] * v.e[1] - u.e[1] * v.e[0],
        );
    }

    pub fn unitVector(self: Self) Self {
        return self.dividedByNum(self.length());
    }

    pub fn approxEq(a: Self, b: Self) bool {
        const r1 = math.approxEqRel(f64, a.x(), b.x(), epsilon);
        const r2 = math.approxEqRel(f64, a.y(), a.y(), epsilon);
        const r3 = math.approxEqRel(f64, a.z(), b.z(), epsilon);
        return r1 and r2 and r3;
    }
};

pub fn printVec(vec: Vec3) !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{d} {d} {d}", .{ vec.e[0], vec.e[1], vec.e[2] });
}

pub const vec3 = Vec3.init;

const epsilon: f32 = 0.00001;
test "Vec3.index" {
    const vec = vec3(12.4, 25.8, 66.7);
    try testing.expect(vec.x() == vec.e[0]);
    try testing.expect(vec.y() == vec.e[1]);
    try testing.expect(vec.z() == vec.e[2]);
    for (0..3) |i| {
        try testing.expect(vec.e[i] == vec.at(i));
    }
}

test "Vec3.add" {
    var a = vec3(1.0, 2.0, 3.0);
    const b = vec3(4.0, 5.0, 6.0);

    try testing.expect(a.add(b).approxEq(vec3(5.0, 7.0, 9.0)));

    _ = a.addAssign(b);
    try testing.expect(a.approxEq(vec3(5.0, 7.0, 9.0)));
}

test "Vec3.sub" {
    var a = vec3(1.0, 2.0, 3.0);
    const b = vec3(4.0, 5.0, 6.0);

    try testing.expect(a.sub(b).approxEq(vec3(-3.0, -3.0, -3.0)));

    _ = a.subAssign(b);
    try testing.expect(a.approxEq(vec3(-3.0, -3.0, -3.0)));
}

test "Vec3.multiply" {
    var a = vec3(1.0, 2.0, 3.0);
    const b = vec3(4.0, 5.0, 6.0);

    try testing.expect(a.multiply(b).approxEq(vec3(4.0, 10.0, 18.0)));

    try testing.expect(a.multiplyNum(3).approxEq(vec3(3.0, 6.0, 9.0)));

    _ = a.multiplyAssign(3);
    try testing.expect(a.approxEq(vec3(3.0, 6.0, 9.0)));
}

test "Vec3.dividedBy" {
    var a = vec3(1.0, 2.0, 3.0);

    try testing.expect(math.approxEqRel(f64, a.dividedByNum(1).x(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(f64, a.dividedByNum(2).y(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(f64, a.dividedByNum(3).z(), 1.0, epsilon));

    _ = a.dividedByAssign(3);
    try testing.expect(a.approxEq(vec3(1.0 / 3.0, 2.0 / 3.0, 3.0 / 3.0)));
}

test "Vec3.vector" {
    const lengthVec = vec3(2.0, 1.0, 2.0);
    const dotVec = vec3(1.0, 2.0, 1.0);

    try testing.expect(math.approxEqRel(f64, lengthVec.length(), 3, epsilon));
    try testing.expect(math.approxEqRel(f64, lengthVec.dot(dotVec), 6, epsilon));

    try testing.expect(lengthVec.cross(dotVec).approxEq(vec3(-3.0, 0.0, 3.0)));

    const unitVec = lengthVec.unitVector();
    try testing.expect(math.approxEqRel(f64, unitVec.length(), 1, epsilon));
}
