# template_c
template_c is a template project for C applications.

## Building
```
zig build [-Drelease | -Dpublic] [-Dtarget=string] [-Dcpu=string]
```

Build and run:
```
zig build run [-Drelease | -Dpublic] [-Dtarget=string] [-Dcpu=string]
```

### Options
```
-Drelease                Create a release build with safety on
-Dpublic                 Create a release build with safety off
-Dtarget=[string]        The CPU architecture, OS, and ABI to build for
-Dcpu=[string]           Target CPU features to add or subtract
```

## License
[MIT](LICENSE)
