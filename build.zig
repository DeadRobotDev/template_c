const std = @import("std");
const log = std.log;
const fs = std.fs;
const mem = std.mem;
const Builder = std.build.Builder;

pub fn build(b: *Builder) !void {
    const cflags: []const []const u8 = &.{
        "-std=c99",
        "-Wall",
        "-Wextra",
        "-pedantic-errors",
    };

    const cflags_debug: []const []const u8 = &.{
        "-g",
        "-gcodeview",
    };

    const target = b.standardTargetOptions(.{});
    const mode = getBuildMode(b);
    const flags = if (mode == .Debug) cflags ++ cflags_debug else cflags;
    const source_files = try getSourceFiles(b, &.{".c"});

    const exe = b.addExecutable("template", null);
    exe.addIncludePath("include");
    exe.addCSourceFiles(source_files.items, flags);
    exe.linkLibC();
    exe.setTarget(target);
    exe.setBuildMode(mode);
    exe.install();

    const run = exe.run();

    if (b.args) |args| {
        run.addArgs(args);
    }

    const run_step = b.step("run", "Run the executable");
    run_step.dependOn(&run.step);
}

fn getBuildMode(b: *Builder) std.builtin.Mode {
    const is_release = b.option(bool, "release", "Create a release build with safety on") orelse false;
    const is_public = b.option(bool, "public", "Create a release build with safety off") orelse false;

    const mode = if (is_release and !is_public)
        std.builtin.Mode.ReleaseSafe
    else if (!is_release and is_public)
        std.builtin.Mode.ReleaseFast
    else if (!is_release and !is_public)
        std.builtin.Mode.Debug
    else x: {
        log.err("Multiple build modes specified", .{});
        break :x std.builtin.Mode.Debug;
    };

    return mode;
}

fn getSourceFiles(b: *Builder, allowed_extensions: []const []const u8) !std.ArrayList([]const u8) {
    var source_files = std.ArrayList([]const u8).init(b.allocator);
    var dir = try fs.cwd().openIterableDir("source", .{});
    var walker = try dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        const ext = fs.path.extension(entry.basename);
        const include_file = for (allowed_extensions) |e| {
            if (mem.eql(u8, ext, e)) {
                break true;
            }
        } else false;

        if (include_file) {
            try source_files.append(b.pathJoin(&.{ "source", b.dupePath(entry.path) }));
        }
    }

    return source_files;
}
