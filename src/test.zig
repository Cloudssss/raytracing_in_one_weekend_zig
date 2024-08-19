const std = @import("std");
const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");

test vec3 {
    std.testing.refAllDecls(vec3);
    std.testing.refAllDecls(ray);
}
