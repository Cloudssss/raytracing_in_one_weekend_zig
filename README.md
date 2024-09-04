# raytracing_in_one_weekend_zig

Simple ray tracing renderer written in zig. Followed [_Ray Tracing in One Weekend_](https://raytracing.github.io/books/RayTracingInOneWeekend.html)

Most of the code is based on the 4.0 version of the tutorial.

## Final Result

![image](/result.png)

## Build and Run

```
zig build --release=fast run >> image.ppm
```

If you are using Nushell, you can use the following command.
```
zig build --release=fast run out> image.ppm
```

Working good on **zig 0.13.0**. It can run on both Windows and Linux.

The time taken to render an image is too long! There might still be room for performance optimization.

If you find the program running too slow, you can change `cam.samples_per_pixel = 500;` in src/main.zig to `cam.samples_per_pixel = 10;`. This will allow you to quickly render an image.

## License

MIT

## Communication

Feel free communicate with me in any way.