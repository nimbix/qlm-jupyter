#FROM tensorflow/tensorflow:2.11.0
FROM python:3.11-slim-bookworm
LABEL maintainer="Nimbix, Inc." \
      license="BSD"

# Update SERIAL_NUMBER to force rebuild of all layers (don't use cached layers)
ARG SERIAL_NUMBER="1.0"
ENV SERIAL_NUMBER ${SERIAL_NUMBER:-20221228.1000}

RUN apt-get update -y && apt-get -y install redir sudo python3-pip pkg-config libfreetype6-dev ImageMagick && \
    chmod 04555 /usr/bin/redir && \
    apt-get clean

# Install the rest of the packages...
COPY requirements.txt /tmp/requirements.txt
RUN python3 -m pip install --upgrade pip && pip3 install -r /tmp/requirements.txt

#ADD https://raw.githubusercontent.com/nimbix/notebook-common/${BRANCH:-master}/install-notebook-common /tmp/install-notebook-common
#RUN export https_proxy=http://129.183.4.13:8080 && chmod 777 /tmp/install-notebook-common &&  /tmp/install-notebook-common -b master -3 && rm /tmp/install-notebook-common
COPY install-notebook-common /tmp/
COPY install-debian.sh /tmp
COPY nimbix_notebook /tmp

RUN chmod 755 /tmp/install-notebook-common && /tmp/install-notebook-common -b master -3 && rm /tmp/install-notebook-common
RUN mkdir /data && chmod 01777 /data
COPY nimbix_notebook /usr/local/bin/nimbix_notebook
RUN chmod 755 /usr/local/bin/nimbix_notebook

EXPOSE 443

COPY NAE/AppDef.json /etc/NAE/AppDef.json
COPY NAE/help.html /etc/NAE/help.html
RUN echo "https://%PUBLICADDR%/?token=%RANDOM64%" >/etc/NAE/url.txt
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://cloud.nimbix.net/api/jarvice/validate
RUN mkdir -p /etc/NAE && touch /etc/NAE/{url.txt,help.html,screenshot.png,screenshot.txt,license.txt,AppDef.json}
