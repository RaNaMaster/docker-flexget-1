FROM alpine:3.9
MAINTAINER wiserain

ARG ATOMIC_PARSLEY_URL="https://bitbucket.org/shield007/atomicparsley/raw/68337c0c05ec4ba2ad47012303121aaede25e6df/downloads/build_linux_x86_64/AtomicParsley"

RUN \
	echo "**** install frolvlad/alpine-python3 ****" && \
	apk add --no-cache python3-dev && \
	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi && \
	if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
	echo "**** install flexget and addons ****" && \
	apk --no-cache add shadow ca-certificates tzdata py3-cryptography && \
	apk add --no-cache py3-lxml g++ gcc ffmpeg libmagic && \
        && curl -L -o AtomicParsley ${ATOMIC_PARSLEY_URL} \
        && install -m 755 ./AtomicParsley /usr/local/bin
	pip3 install --upgrade \
		transmissionrpc \
		beautifulsoup4==4.6.0 \
		mechanicalsoup \
		requests==2.21.0 \
		certifi==2017.4.17 \
		chardet==3.0.3 \
		idna==2.5 \
		urllib3==1.24.2 \
		youtube-dl \
		cython \
		six==1.10.0 \
		flexget && \
	sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd && \
	echo "**** cleanup ****" && \
	rm -rf \
		/tmp/* \
		/root/.cache

# copy local files
COPY files/ /

# add default volumes
VOLUME /config /data
WORKDIR /config

# expose port for flexget webui
EXPOSE 3539 3539/tcp

# run init.sh to set uid, gid, permissions and to launch flexget
RUN chmod +x /scripts/init.sh
CMD ["/scripts/init.sh"]
