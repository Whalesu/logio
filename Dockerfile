FROM centos:7

# Propert permissions
ENV CONTAINER_USER logio
ENV CONTAINER_UID 1000
ENV CONTAINER_GROUP logio
ENV CONTAINER_GID 1000

RUN /usr/sbin/groupadd --gid $CONTAINER_GID logio && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --create-home --shell /bin/bash logio

# install dev tools
ENV VOLUME_DIRECTORY=/opt/server
RUN curl --silent --location https://rpm.nodesource.com/setup_14.x | bash - && \
    yum install -y \
    curl \
    nodejs \
    wget \
    vim \
    make && \
    yum clean all && rm -rf /var/cache/yum/* && \
    mkdir -p ${VOLUME_DIRECTORY}/keys && \
    chown -R $CONTAINER_UID:$CONTAINER_GID ${VOLUME_DIRECTORY}/keys && \
    npm install -g log.io --user 'root' && \
    npm install -g log.io-file-input --user 'root'

ENV DELAYED_START=
ENV LOGIO_ADMIN_USER=
ENV LOGIO_ADMIN_PASSWORD=
ENV LOGIO_TCP_MASTER_HOST=
ENV LOGIO_TCP_MASTER_PORT=
ENV LOGS_DIRECTORIES=
ENV LOG_FILE_PATTERN=
ENV SERVER_DEBUG_MODE=false
ENV LOG_FILE_SEARCH_DEPTH=20
ENV LOG_SOURCE_MAX=2

VOLUME ["${VOLUME_DIRECTORY}"]
EXPOSE 6688 6689

USER $CONTAINER_UID
COPY imagescripts/*.sh /opt/logio/
ENTRYPOINT ["/opt/logio/docker-entrypoint.sh"]
CMD ["logio"]
