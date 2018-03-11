# IPsec with Docker

This project can successfully set up an IPsec connection between two docker containers either through a pre-shared key or a signed certificate.

Both containers use the same `Dockerfile`, but are passed different arguments by `docker-compose.yaml`. This means we can build the container with different keys and IP addresses in configurations, but use the same `Dockerfile`.

This defaults to running the containers with certificate configurations. However, if you wish to run with pre-shared key configuration, all you have to do is change the line `AUTH_MODE: cert` to `AUTH_MODE: psk` in `docker-compose.yaml`. Unfortunately, this line exists twice in the file, and you have to change both instances. Sorry!

## How to run

You can run this project by running:

```bash
openssl req \
  -nodes -x509 -newkey rsa:4096 \
  -keyout moon_key.pem -out moon_cert.pem \
  -days 365

openssl req \
  -nodes -x509 -newkey rsa:4096 \
  -keyout sun_key.pem -out sun_cert.pem \
  -days 365

docker-compose up --build
``` 

This will start up two containers with IPsec between them. You can see this works in two ways. Firstly, the last log for each container should be `connection 'cert-conn' established successfully`.

Secondly, if you run:
- `echo "testing IPsec" | nc moon 12345` on the `sun` container.
- `nc -l -p 12345` on the `moon` container.
- `tcpdump --interface <docker network interface> -X` on your host machine.

You will not be able to see the `"testing IPsec"` message in the `tcpdump` output.

## Notes

Setting up the `ipsec.conf` was not too difficult. I simply started with the configuration shown to us in the lectures, stripped specifics such as IPs from the configuration, and added the two `conn` entries. The ciphers from the lecture slides were strong enough, so they were left as is.

This was a fun assignment to do in docker, and I ran into surprisingly few issues along the way. Setting up two separate containers from a single `Dockerfile` was interesting, and not as painful as I expected. Unfortunately I didn't have enough time to write tests for the configuration!

