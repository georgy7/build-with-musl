# Why Musl?

Two reasons.

1. **Build once, run everywhere** (all Linux distros). Executables smaller, than with glibc.
2. Musl has the very permissive MIT license.

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

    docker run -it clangmusl

## Step 3. Build `hello.c`

    docker run -v $(pwd):/workDir -it clangmusl /workDir/build_single.sh hello.c hello-musl
    
    docker run -v $(pwd):/workDir -it clangmusl /workDir/build_single_release.sh \
    hello.c hello-musl-release

`$(pwd)` means the current host directory.

## Step 4. Test on other distros.

    docker run -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl
    Hi!

    docker run -v $(pwd):/workDir -it busybox:glibc /workDir/hello-musl
    Hi!

    docker run -v $(pwd):/workDir -it busybox:musl /workDir/hello-musl
    Hi!

    docker run -v $(pwd):/workDir -it busybox:uclibc /workDir/hello-musl
    Hi!

    docker run -v $(pwd):/workDir -it hello-world /workDir/hello-musl
    Hi!

    ./hello-musl 
    Hi!

    file hello-musl
    hello-musl: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

And now, the stripped version:

    docker run -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl-release
    Hi!

    docker run -v $(pwd):/workDir -it busybox:glibc /workDir/hello-musl-release
    Hi!

    docker run -v $(pwd):/workDir -it busybox:musl /workDir/hello-musl-release
    Hi!

    docker run -v $(pwd):/workDir -it busybox:uclibc /workDir/hello-musl-release
    Hi!

    docker run -v $(pwd):/workDir -it hello-world /workDir/hello-musl-release
    Hi!

    ./hello-musl-release
    Hi!

    file hello-musl-release
    hello-musl-release: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped
