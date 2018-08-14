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

    docker run --rm -it clangmusl

## Step 3. Build `hello.c`

    docker run --rm -v $(pwd):/workDir -it clangmusl /workDir/build_single.sh hello.c hello-musl
    
    docker run --rm -v $(pwd):/workDir -it clangmusl /workDir/build_single_release.sh \
    hello.c hello-musl-release

`$(pwd)` means the current host directory.

## Step 4. Test on other distros.

    docker run --rm -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:glibc /workDir/hello-musl
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:musl /workDir/hello-musl
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:uclibc /workDir/hello-musl
    Hi!

    docker run --rm -v $(pwd):/workDir -it hello-world /workDir/hello-musl
    Hi!

    ./hello-musl 
    Hi!

    file hello-musl
    hello-musl: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, not stripped

And now, the stripped version:

    docker run --rm -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl-release
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:glibc /workDir/hello-musl-release
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:musl /workDir/hello-musl-release
    Hi!

    docker run --rm -v $(pwd):/workDir -it busybox:uclibc /workDir/hello-musl-release
    Hi!

    docker run --rm -v $(pwd):/workDir -it hello-world /workDir/hello-musl-release
    Hi!

    ./hello-musl-release
    Hi!

    file hello-musl-release
    hello-musl-release: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, stripped

# Building single Nim file

Install the image for compiling, build the other image for building:

```
docker pull nimlang/nim:0.18.0-alpine
docker build --tag nimclangmusl NimClangMusl
```

Transpile to C. Optionally use the `--threads:on` option.

```
docker run --rm -v `pwd`:/usr/src/app -w /usr/src/app \
    nimlang/nim:0.18.0-alpine nim c \
    -d:release --opt:size --compileOnly hello2.nim

sudo chown -R $USER nimcache
```

Copy both `nim_single.sh` and `nim_single_inner.sh` files to the folder with your source code.

Modify `nim_single_inner.sh` if needed.

Build:

```
./nim_single.sh hello2.c hello2
```

Test it on various distros.

    docker run --rm -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/nimcache/hello2
    docker run --rm -v $(pwd):/workDir -it busybox:glibc /workDir/nimcache/hello2
    docker run --rm -v $(pwd):/workDir -it busybox:musl /workDir/nimcache/hello2
    docker run --rm -v $(pwd):/workDir -it busybox:uclibc /workDir/nimcache/hello2
    docker run --rm -v $(pwd):/workDir -it hello-world /workDir/nimcache/hello2
    ./nimcache/hello2

And size of this executable is

```
$ wc --bytes nimcache/hello2
34280 nimcache/hello2

$ md5sum nimcache/hello2
50bea5fe693b57d602b674528b28c42e  nimcache/hello2
```

Also, there is [the great article](https://hookrace.net/blog/nim-binary-size/) about
reducing binary size in Nim programming language.
