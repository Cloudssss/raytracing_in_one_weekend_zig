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
};

pub const vec3 = Vec3.new;
