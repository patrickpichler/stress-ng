FROM debian:12 AS build

ARG STRIP

RUN apt-get update && apt-get install -y build-essential libacl1-dev zlib1g-dev libbsd-dev libeigen3-dev libcrypt-dev libjpeg-dev libmpfr-dev libgmp-dev libkeyutils-dev libapparmor-dev apparmor libaio-dev libcap-dev libsctp-dev libjudy-dev libatomic1 libxxhash-dev

WORKDIR /src

ADD . stress-ng

WORKDIR /src/stress-ng

RUN mkdir install-root && rm -rf configs config.h && VERBOSE=1 make -f Makefile.config -j $(nproc) && VERBOSE=1 STATIC=1 make -j $(nproc)

RUN if [[ -z "STRIP" ]]; then strip stress-ng; else echo "not stripping binary"; fi

RUN make DESTDIR=install-root/ install

####### actual image ########

FROM debian:12

COPY --from=build /src/stress-ng/install-root/ /

ENTRYPOINT ["/usr/bin/stress-ng"]
CMD ["--help"]
