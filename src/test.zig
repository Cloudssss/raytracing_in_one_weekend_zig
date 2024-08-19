const std = @import("std");
const vec3 = @import("vec3.zig");

test vec3 {
    std.testing.refAllDecls(vec3);
}
