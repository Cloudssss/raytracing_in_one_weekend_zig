const math = @import("std").math;
const testing = @import("std").testing;

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
        return vec3(u.e[1] * v.e[2] - u.e[2] * v.e[1], u.e[2] * v.e[0] - u.e[0] * v.e[2], u.e[0] * v.e[1] - u.e[1] * v.e[0]);
    }

    pub fn unitVector(self: Self) Self {
        return self.dividedByNum(self.length());
    }
};

pub const vec3 = Vec3.new;

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

    try testing.expect(math.approxEqRel(a.add(b).x(), 5.0, epsilon));
    try testing.expect(math.approxEqRel(a.add(b).y(), 7.0, epsilon));
    try testing.expect(math.approxEqRel(a.add(b).z(), 9.0, epsilon));

    try testing.expect(math.approxEqRel(a.addAssign(b).x(), 5.0, epsilon));
    try testing.expect(math.approxEqRel(a.addAssign(b).y(), 7.0, epsilon));
    try testing.expect(math.approxEqRel(a.addAssign(b).z(), 9.0, epsilon));
}

test "Vec3.sub" {
    var a = vec3(1.0, 2.0, 3.0);
    const b = vec3(4.0, 5.0, 6.0);

    try testing.expect(math.approxEqRel(a.add(b).x(), 3.0, epsilon));
    try testing.expect(math.approxEqRel(a.add(b).y(), 3.0, epsilon));
    try testing.expect(math.approxEqRel(a.add(b).z(), 3.0, epsilon));

    try testing.expect(math.approxEqRel(a.addAssign(b).x(), 3.0, epsilon));
    try testing.expect(math.approxEqRel(a.addAssign(b).y(), 3.0, epsilon));
    try testing.expect(math.approxEqRel(a.addAssign(b).z(), 3.0, epsilon));
}

test "Vec3.multiply" {
    var a = vec3(1.0, 2.0, 3.0);
    const b = vec3(4.0, 5.0, 6.0);

    try testing.expect(math.approxEqRel(a.multiply(b).x(), 4.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiply(b).y(), 10.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiply(b).z(), 18.0, epsilon));

    try testing.expect(math.approxEqRel(a.multiplyNum(3).x(), 3.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiplyNum(3).y(), 6.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiplyNum(3).z(), 9.0, epsilon));

    try testing.expect(math.approxEqRel(a.multiplyAssign(b).x(), 4.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiplyAssign(b).y(), 10.0, epsilon));
    try testing.expect(math.approxEqRel(a.multiplyAssign(b).z(), 18.0, epsilon));
}

test "Vec3.dividedBy" {
    var a = vec3(1.0, 2.0, 3.0);

    try testing.expect(math.approxEqRel(a.dividedByNum(1).x(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(a.dividedByNum(2).y(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(a.dividedByNum(3).z(), 1.0, epsilon));

    try testing.expect(math.approxEqRel(a.dividedByAssign(1).x(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(a.dividedByAssign(2).y(), 1.0, epsilon));
    try testing.expect(math.approxEqRel(a.dividedByAssign(3).z(), 1.0, epsilon));
}

test "Vec3.vector" {
    const lengthVec = vec3(2.0, 1.0, 2.0);
    const dotVec = vec3(1.0, 2.0, 1.0);

    try testing.expect(math.approxEqRel(lengthVec.length(), 3, epsilon));
    try testing.expect(math.approxEqRel(lengthVec.dot(dotVec), 6, epsilon));

    try testing.expect(math.approxEqRel(lengthVec.cross(dotVec).x(), -3, epsilon));
    try testing.expect(math.approxEqRel(lengthVec.cross(dotVec).y(), 0, epsilon));
    try testing.expect(math.approxEqRel(lengthVec.cross(dotVec).z(), 3, epsilon));

    const unitVec = lengthVec.unitVector();
    try testing.expect(math.approxEqRel(unitVec.length(), 1, epsilon));
}
