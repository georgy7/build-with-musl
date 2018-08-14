FROM alpine:3.5
RUN apk add --no-cache clang
RUN apk add --no-cache musl-dev
RUN apk add --no-cache binutils

RUN apk add --no-cache curl
RUN curl https://nim-lang.org/download/nim-0.18.0.tar.xz > nim.tar.xz
RUN tar x -f nim.tar.xz
RUN mv /nim-0.18.0 /nim
