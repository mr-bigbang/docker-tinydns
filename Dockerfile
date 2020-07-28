FROM alpine
RUN apk add --update curl build-base

# Daemontools
RUN mkdir -p /package && chmod 1755 /package
WORKDIR /package
RUN curl --silent https://cr.yp.to/daemontools/daemontools-0.76.tar.gz -o daemontools-0.76.tar.gz
RUN tar -xf daemontools-0.76.tar.gz && rm daemontools-0.76.tar.gz
RUN cd admin/daemontools-0.76 && sed -i 's/gcc -O2/gcc -O2 -include \/usr\/include\/errno.h/g' src/conf-cc && package/install

# Djbdns
WORKDIR /tmp
RUN curl --silent https://cr.yp.to/djbdns/djbdns-1.05.tar.gz -o djbdns-1.05.tar.gz
RUN tar -xzf /tmp/djbdns-1.05.tar.gz && rm djbdns-1.05.tar.gz
# Add IPv6 patch by Fefe
# https://fefe.de/dns
RUN curl --silent https://www.fefe.de/dns/djbdns-1.05-test28.diff.xz -o djbdns-1.05-test28.diff.xz
RUN unxz /tmp/djbdns-1.05-test28.diff.xz
RUN cd djbdns-1.05 && patch -p1 < ../djbdns-1.05-test28.diff && rm /tmp/djbdns-1.05-test28.diff
RUN cd djbdns-1.05 && echo gcc -O2 -include /usr/include/errno.h > conf-cc && make && make setup check

FROM alpine
# Copy compiled binaries
COPY --from=0 /usr/local/bin/ /usr/local/bin/
COPY --from=0 /package/ /package/
COPY --from=0 /command/ /command/

RUN apk add --update make

RUN adduser --system --no-create-home tinydns
RUN adduser --system --no-create-home dnslog

ENV ROOT /srv/tinydns
RUN tinydns-conf tinydns dnslog $ROOT 0.0.0.0

VOLUME $ROOT
EXPOSE 53/udp

WORKDIR $ROOT
ENTRYPOINT ./run
