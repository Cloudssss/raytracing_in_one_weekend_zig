const std = @import("std");
const Ray = @import("ray.zig").Ray;
const Hittable = @import("hittable.zig").Hittable;
const HitRecord = @import("hittable.zig").HitRecord;
const Interval = @import("interval.zig").Interval;
const interval = @import("interval.zig").interval;
const ArrayList = @import("std").ArrayList;

pub const HittableList = struct {
    objects: ArrayList(Hittable),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{
            .objects = ArrayList(Hittable).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.objects.deinit();
    }

    pub fn add(self: *Self, object: Hittable) !void {
        try self.objects.append(object);
    }

    pub fn hit(self: Self, r: Ray, ray_t: Interval, rec: *HitRecord) bool {
        var temp_hit_record: HitRecord = undefined;
        const temp_rec = &temp_hit_record;
        var hit_anything = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |object| {
            if (object.hit(r, interval(ray_t.min, closest_so_far), temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec.*;
            }
        }

        return hit_anything;
    }
};
