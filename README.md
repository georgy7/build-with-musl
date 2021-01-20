# Why Musl?

Two reasons.

1. **Build once, run everywhere** (all Linux distros). Executables smaller, than with glibc.
2. Musl has the very permissive MIT license.

--------

You may like [the collection of single file libs](https://github.com/nothings/single_file_libs).

# Cons

I do not recommend this method for anything related to GUI.
You [can not](https://lobste.rs/s/qx5zuo/how_create_portable_linux_binaries_even)
statically link with X11, OpenGL, GTK anyway.

For cross-platform desktop GUI application, IMO, it's much easier to use JVM (Swing/JOGL/LWJGL),
probably .Net, Python (Tkinter included). Or you can use a standard set of libraries with [Flatpak](https://docs.flatpak.org/en/latest/available-runtimes.html) or [Snap](https://snapcraft.io/docs/creating-a-snap). Both platforms allow you to distribute closed-source software.

# Single C file

## Regular build

    clang -std=c11 hello.c --static -o hello-clang
    clang -std=c11 hello.c -o hello-clang-dynamic
    gcc -std=c11 hello.c --static -o hello-gcc
    gcc -std=c11 hello.c -o hello-gcc-dynamic

That's what I got on my 64-bit Ubuntu system:

| Name                    | Size (KB) | Works on Tiny Core Linux?         |
| ----------------------- | --------: | :-------------------------------: |
| hello-clang             |     887.4 | YES                               |
| hello-clang-dynamic     |       8.5 | panic: standard_init_linux.go:178 |
| hello-gcc               |     887.3 | YES                               |
| hello-gcc-dynamic       |       8.4 | panic: standard_init_linux.go:178 |
| *hello-musl*            |   *120.5* | *YES*                             |
| *hello-musl-release* (strip-all)   |    *17.2* | *YES*                             |

1/7 by size (strip-all is a cheating, I suppose)! So, how to get it?

## Step 1. Install Docker.

On Ubuntu:

    sudo apt-get install docker.io

    sudo usermod -aG docker $USER
    
Then relogin.

## Step 2. Download Alpine Linux + Clang

Clone this git repository. Go to its directory. Then:

    docker build --tag clangmusl ClangMusl

You can browse it now (print `exit` to exit):

    docker run --rm -it clangmusl

## Step 3. Build `hello.c`

    docker run --rm -v "$(pwd)":/workDir -it clangmusl /workDir/build_single.sh hello.c hello-musl
    
    docker run --rm -v "$(pwd)":/workDir -it clangmusl /workDir/build_single_release.sh \
    hello.c hello-musl-release

"$(pwd)" means the current host directory.

## Step 4. Test on other distros.

    docker run --rm -v "$(pwd)":/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:glibc /workDir/hello-musl
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:musl /workDir/hello-musl
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:uclibc /workDir/hello-musl
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it hello-world /workDir/hello-musl
    Hi!

    ./hello-musl 
    Hi!

    file hello-musl
    hello-musl: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

And now, the stripped version:

    docker run --rm -v "$(pwd)":/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl-release
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:glibc /workDir/hello-musl-release
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:musl /workDir/hello-musl-release
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it busybox:uclibc /workDir/hello-musl-release
    Hi!

    docker run --rm -v "$(pwd)":/workDir -it hello-world /workDir/hello-musl-release
    Hi!

    ./hello-musl-release
    Hi!

    file hello-musl-release
    hello-musl-release: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped

# Building Nim script

```
docker pull nimlang/nim:1.4.2-alpine
```

```
docker run --rm -v "`pwd`":/workDir -w /workDir \
    nimlang/nim:1.4.2-alpine nim c \
    -d:release --opt:size --passL:-static hello2.nim
```

Test it on various distros.

    docker run --rm -v "$(pwd)":/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello2
    docker run --rm -v "$(pwd)":/workDir -it busybox:glibc /workDir/hello2
    docker run --rm -v "$(pwd)":/workDir -it busybox:musl /workDir/hello2
    docker run --rm -v "$(pwd)":/workDir -it busybox:uclibc /workDir/hello2
    docker run --rm -v "$(pwd)":/workDir -it hello-world /workDir/hello2
    ./hello2

And size of this executable is

```
wc --bytes hello2
160352 hello2

md5sum hello2
46b35faf93ed264f21f2bd14fe943dbe  hello2

strip hello2
wc --bytes hello2
35000

md5sum hello2
4a6d882ec8c84e9537e203089a7dc017  hello2

file hello2
hello2: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, stripped

ldd hello2
	statically linked
```

A bit more complex example.

```
docker run --rm -v "`pwd`":/workDir -w /workDir \
    nimlang/nim:1.4.2-alpine nim c --threads:on \
    -d:release --opt:size --passL:-static race.nim

wc --bytes race
275424 race

file race
race: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, with debug_info, not stripped

ldd race
	statically linked

md5sum race
1934b9430e1374788e725e5c07fba0f8  race


strip race

wc --bytes race
51456 race

file race
race: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, stripped

ldd race
	statically linked

md5sum race
22e90027056a63c20500c61d3a7e0674  race
```

```
./race
docker run --rm -v "$(pwd)":/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/race
docker run --rm -v "$(pwd)":/workDir -it busybox:glibc /workDir/race
docker run --rm -v "$(pwd)":/workDir -it busybox:musl /workDir/race
docker run --rm -v "$(pwd)":/workDir -it busybox:uclibc /workDir/race
```
