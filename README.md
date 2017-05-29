# Why Musl?

Two reasons.

1. Portable (zero-dependency) executables, that are smaller, than ones with glibc.
2. This is the good way to get rid of glibc, if you are a GPL-paranoid like me. Musl has MIT license.

# Single C file

## Regular build

    gcc -std=c11 hello.c -o hello-gcc-dynamic
    gcc -std=c11 hello.c --static -o hello-gcc
    clang -std=c11 hello.c -o hello-clang-dynamic
    clang -std=c11 hello.c --static -o hello-clang

That's what I got on my 64-bit Ubuntu system:

| Name                    | Size (KB) | Works on Tiny Core Linux          |
| ----------------------- | --------: | --------------------------------- |
| hello-clang             |     887.4 | YES                               |
| hello-clang-dynamic     |       8.5 | panic: standard_init_linux.go:178 |
| hello-gcc               |     887.3 | YES                               |
| hello-gcc-dynamic       |       8.4 | panic: standard_init_linux.go:178 |
| *hello-musl*            |   *120.5* | *YES*                             |

So, how to get it.

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

`$(pwd)` means the current host directory.

## Step 4. Test on other distros.

    docker run -v $(pwd):/workDir -it tatsushid/tinycore:8.0-x86_64 /workDir/hello-musl
