FROM debian:latest
LABEL maintainer "publicarray"
LABEL description "NTP reference implementation, refactored for security"
ENV REVISION 0

ENV NTPSEC_BUILD_DEPS pkg-config m4 wget tar gcc bison python-dev libssl-dev libssl-dev libcap-dev libseccomp-dev pps-tools
RUN apt-get update \
    && apt-get install -y $NTPSEC_BUILD_DEPS \
    && rm -rf /var/lib/apt/lists/*

# https://github.com/ntpsec/ntpsec/releases
ENV NTPSEC_VERSION 1.1.3
ENV NTPSEC_DOWNLOAD_URL "https://ftp.ntpsec.org/pub/releases/ntpsec-${NTPSEC_VERSION}.tar.gz"
ENV NTPSEC_SHA256 226b4b29d5166ea3d241a24f7bfc2567f289cf6ed826d8aeb9f2f261c1836bde

RUN set -x && \
    mkdir -p /tmp && \
    cd /tmp && \
    wget -O ntpsec.tar.gz $NTPSEC_DOWNLOAD_URL && \
    echo "${NTPSEC_SHA256} *ntpsec.tar.gz" | sha256sum -c - && \
    tar xzf ntpsec.tar.gz && \
    cd ntpsec-${NTPSEC_VERSION} && \
    ## uses out-of-date package names \
    # ./buildprep && \
    ./waf configure && \
    ./waf build && \
    ./waf check && \
    ./waf install

#------------------------------------------------------------------------------#
FROM debian:latest

ENV NTPSEC_RUN_DEPS wget libssl1.1 libcap2 libseccomp2 pps-tools
# python

RUN apt-get update \
    && apt-get install -y $NTPSEC_RUN_DEPS \
    && rm -rf /var/lib/apt/lists/*

COPY --from=0 /usr/local/sbin/ntpd /usr/local/sbin/ntpd
COPY --from=0 /usr/local/bin/ntp* /usr/local/bin/
# COPY --from=0 /usr/local/lib/python2.7/dist-packages/ntp/ /usr/local/lib/python2.7/dist-packages/ntp/

RUN set -x && \
    mkdir -p /var/ntpsec/ && \
    addgroup --system ntpsec && \
    adduser --system --disabled-password --disabled-login --no-create-home --shell /sbin/nologin --gecos ntpsec --ingroup ntpsec ntpsec && \
    chown -R ntpsec:ntpsec /var/ntpsec/

# COPY entrypoint.sh /
COPY ntp.conf /etc/ntp.conf

EXPOSE 123/udp

RUN ntpd --version \
    && ntpleapfetch

## ntpq: can't find Python NTP library -- check PYTHONPATH.
## libpython2.7.so.1.0: cannot open shared object file: No such file or directory
# RUN ntpq --version

# HEALTHCHECK --interval=60s --timeout=5s CMD ntpq -p > /dev/null

ENTRYPOINT ["/usr/local/sbin/ntpd"]

CMD ["-n", "-i", "/var/ntpsec/", "-u", "ntpsec:ntpsec"]
# CMD ["-n", "-i", "/var/ntpsec/", "-u", "_ntpsec:_ntpsec", "-N"] # sched_setscheduler(): Operation not permitted
