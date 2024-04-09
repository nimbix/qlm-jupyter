
FROM rockylinux:9

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER="20240409.1000"
ENV SERIAL_NUMBER=${SERIAL_NUMBER}

RUN echo "max_parallel_downloads=20" >> /etc/dnf/dnf.conf
RUN echo "fastestmirror=True" >> /etc/dnf/dnf.conf
RUN dnf update -y --refresh

RUN dnf update -y && \
    dnf install -y \
        python3.11-devel\
        python3.11-pip\
        gcc\
        openmpi-devel

# First image is based on Ubuntu Focal
RUN curl -H 'Cache-Control: no-cache' \
        https://raw.githubusercontent.com/nimbix/jarvice-desktop/master/install-nimbix.sh \
        | bash

ENV PATH=/usr/lib64/openmpi/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/JARVICE/tools/bin
COPY requirements.txt /tmp/requirements.txt
RUN python3.11 -m pip install -U -r /tmp/requirements.txt

COPY scripts /usr/local/scripts

COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/screenshot.png /etc/NAE/screenshot.png
COPY NAE/help.html /etc/NAE/help.html
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && touch /etc/NAE/{url.txt,help.html,screenshot.png,screenshot.txt,license.txt,AppDef.json}
