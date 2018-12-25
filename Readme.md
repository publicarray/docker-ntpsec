This image is designed to be used as part of the [www.pool.ntp.org](https://ntppool.org) project.
Default is for the Australian zone

```sh
# Build
docker build t publicarray/ntpsec .
# Run
docker run -it --rm --name ntpsec -p123:123/udp --cap-add SYS_TIME --cap-add SYS_NICE publicarray/ntpsec
# Run detached
docker run -d --rm --name ntpsec -p123:123/udp --cap-add SYS_TIME --cap-add SYS_NICE publicarray/ntpsec
# Run detached and use host network
docker run -d --rm --name ntpsec --net=host --cap-add SYS_TIME --cap-add SYS_NICE publicarray/ntpsec
# BYO (bring your own) config file
docker run -it --rm --name ntpsec -p123:123/udp --cap-add SYS_TIME --cap-add SYS_NICE -v "$(pwd)"/ntp.conf:/etc/ntp.conf:ro publicarray/ntpsec
# Or your own arguments
docker run -it --rm --name ntpsec -p123:123/udp publicarray/ntpsec --help
```

```sh
# https://docs.docker.com/compose/compose-file/#cap_add-cap_drop
# this will not work :'( > Note: These options are ignored when deploying a stack in swarm mode with a (version 3) Compose file.
# https://github.com/docker/swarmkit/pull/1565
# docker stack deploy --compose-file=docker-compose.yml ntp-server
```

## Prevent conntrack from filling up

```sh
# get current status:
$ conntrack -C
$ sysctl net.netfilter.nf_conntrack_max

# disable conntrack on NTP port 123
$ iptables -t raw -A PREROUTING -p udp -m udp --dport 123 -j NOTRACK
$ iptables -t raw -A OUTPUT -p udp -m udp --sport 123 -j NOTRACK
