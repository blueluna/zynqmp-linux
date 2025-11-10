# Boot ZynqMP

Booting Xilinx ZynqMP with as few Xilinx tools possible.

## Boards

Tested with following boards,

 - [Trenz-Electronic TE0802-02](./te0802-02/README.md), currently out of date
 - [Myir FZ3](./myir-fz3/README.md)

## Required packages,

Following packages might be required to be installed,

 * `bison`
 * `dtc`
 * `flex`
 * `git-lfs`
 * `gnutls-dev` / `gnutls-devel`
 * `libssl-dev` / `openssl-devel`, `openssl-devel-engines`
 * `uuid-dev` / `libuuid-devel`

## Boot Loader

U-Boot is used see [the u-boot directory](./u-boot/README.md).

## Linux Kernel

How to build the Linux kernel, See [the linux directory](./linux/README.md).

## Root File System

For building Debian, See [the debian directory](./debian/README.md).