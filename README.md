# DJB's Tinydns inside a Docker container

Alpine based tinydns docker image.

Run: `docker run -d -v tinydns:/srv/tinydns -p 127.0.0.2:53:53/udp --restart always --name tinydns mrbigbang/tinydns` and point your /etc/resolv.conf to 127.0.0.2

Or via docker-compose: 
```yaml
version: "3.8"

services:
  tinydns:
    image: mrbigbang/tinydns
    restart: "always"
    ports:
      - "127.0.0.2:53:53/udp"
    volumes:
      - tinydns:/srv/tinydns

volumes:
  tinydns:
    driver: local
```

Don't forget to configure tinydns according to the official documentation: https://cr.yp.to/djbdns.html
