This image is designed to be used as servers as part of the [www.pool.ntp.org](https://ntppool.org) project.

```sh
# Build
docker build t publicarray/ntpsec .
# Run
docker run -it --rm --name ntpsec --cap-add SYS_TIME --cap-add SYS_NICE publicarray/ntpsec
# BYO (bring your own) config file
docker run -it --rm --name ntpsec --cap-add SYS_TIME --cap-add SYS_NICE -v "$(pwd)"/ntp.conf:/etc/ntp.conf:ro publicarray/ntpsec
# Or your own arguments
docker run -it --rm --name ntpsec publicarray/ntpsec --help
```
