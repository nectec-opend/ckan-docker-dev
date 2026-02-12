FROM python:3.9-slim-bookworm

# -------------------------
# ENV
# -------------------------
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC
ENV APP_DIR=/srv/app
ENV SRC_DIR=${APP_DIR}/src
ENV EXT_DIR=${APP_DIR}/src_extensions
ENV CONFIG_DIR=${APP_DIR}/conf
ENV CKAN_INI=${CONFIG_DIR}/ckan.ini
ENV CKAN_STORAGE_PATH=/var/lib/ckan
ENV CKAN_REF=ckan-2.10.7
ENV LC_ALL=en_US.UTF-8
ENV CKAN__PLUGINS="image_view text_view recline_view datastore envvars"

WORKDIR ${APP_DIR}

# -------------------------
# system dependencies
# -------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    locales \
    tzdata \
    libpq-dev \
    gcc \
    g++ \
    make \
    libxml2-dev \
    libxslt1-dev \
    libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libjpeg-dev \
    redis-tools \
    libmagic1 \
    libmagic-dev \
    && rm -rf /var/lib/apt/lists/*

# locale
RUN sed -i "/$LC_ALL/s/^# //g" /etc/locale.gen && \
    locale-gen && \
    update-locale LANG=${LC_ALL}

# -------------------------
# python tools
# -------------------------
RUN pip install --upgrade pip "setuptools<71" wheel

# -------------------------
# directories
# -------------------------
RUN mkdir -p ${SRC_DIR} ${EXT_DIR} ${CKAN_STORAGE_PATH} ${CONFIG_DIR}

# -------------------------
# install CKAN
# -------------------------
RUN pip install -e \
    git+https://github.com/ckan/ckan.git@${CKAN_REF}#egg=ckan && \
    pip install -r ${SRC_DIR}/ckan/requirements.txt && \
    pip install -r ${SRC_DIR}/ckan/dev-requirements.txt && \
    pip install -e git+https://github.com/okfn/ckanext-envvars.git@v0.0.6#egg=ckanext-envvars

# -------------------------
# CKAN dev requirements
# -------------------------
# RUN pip install -r \
#     https://raw.githubusercontent.com/ckan/ckan/${CKAN_REF}/requirements.txt
# RUN pip install -r \
#     https://raw.githubusercontent.com/ckan/ckan/${CKAN_REF}/dev-requirements.txt

# -------------------------
# optional dev helpers
# -------------------------
# RUN pip install ipython debugpy watchdog

# -------------------------
# generate ckan.ini
# -------------------------
# RUN ckan generate config ${CKAN_INI} && \
#     ckan config-tool ${CKAN_INI} "beaker.session.secret = " && \
#     ckan config-tool ${CKAN_INI} "ckan.site_url = http://localhost:5000" && \
#     ckan config-tool ${CKAN_INI} "ckan.plugins = image_view text_view recline_view datastore envvars"
COPY setup/start_ckan_development.sh ${APP_DIR}/setart_ckan_development.sh
COPY setup/prerun.py ${APP_DIR}/prerun.py
RUN chmod +x ${APP_DIR}/setart_ckan_development.sh ${APP_DIR}/prerun.py

# COPY docker-entrypoint.sh /docker-entrypoint.sh
# RUN chmod +x /docker-entrypoint.sh

# ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 5000

CMD ["/srv/app/setart_ckan_development.sh"]
# CMD ["ckan", "-c", "/srv/app/conf/ckan.ini", "run", "--host", "0.0.0.0"]
