# Arch Linux

## Quick start

Build a root file system,
```shell
$ ./build.sh
```

Extract to the target,
```shell
$ tar -xf archlinux/archlinux.tar.xz -C /run/media/user/myir-fz3/
```

Extract kernel modules to the target,
```shell
$ mkdir -p /run/media/user/myir-fz3/lib/modules/6.17.7/
$ tar -xf myir-fz3/output/linux-6.17.7/modules/6.17.7.tar.xz -C /run/media/user/myir-fz3/lib/modules/6.17.7/
```

