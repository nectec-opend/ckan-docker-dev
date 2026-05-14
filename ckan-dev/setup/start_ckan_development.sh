#!/bin/sh
set -e

echo "🚀 Starting CKAN in DEV MODE"

echo "🔍 Checking CKAN config at ${CKAN_INI}"

if [ ! -f "${CKAN_INI}" ]; then
  echo "📝 ckan.ini not found, generating..."
  ckan generate config "${CKAN_INI}"
  echo "✅ ckan.ini generated"
else
  echo "✅ ckan.ini already exists"
fi

echo "🐞 Enabling debug mode"
ckan config-tool $CKAN_INI -s DEFAULT "debug = true"

# Generate secrets if empty
if grep -E "beaker.session.secret ?= ?$" $CKAN_INI; then
    echo "🔐 Generating secrets"
    SECRET=$(python3 -c 'import secrets; print(secrets.token_urlsafe())')
    JWT_SECRET=$(python3 -c 'import secrets; print("string:" + secrets.token_urlsafe())')

    ckan config-tool $CKAN_INI "beaker.session.secret=${SECRET}"
    ckan config-tool $CKAN_INI "WTF_CSRF_SECRET_KEY=${SECRET}"
    ckan config-tool $CKAN_INI "api_token.jwt.encode.secret=${JWT_SECRET}"
    ckan config-tool $CKAN_INI "api_token.jwt.decode.secret=${JWT_SECRET}"
fi

echo "🔌 Installing DEV extensions..."

pip install --upgrade "pip<26" "setuptools<70"

for dir in /srv/app/src_extensions/*; do
  if [ -f "$dir/setup.py" ]; then
    ext_name=$(basename "$dir")
    echo "📦 Installing $ext_name (editable mode)"
    pip install -e "$dir"

    if [ -f "$dir/requirements.txt" ]; then
      echo "📦 Installing requirements for $ext_name"
      pip install -r "$dir/requirements.txt"
    fi

    # 🔥 Special handling for xloader
    if [ "$ext_name" = "ckanext-xloader" ]; then
      echo "🔐 Installing requests[security] for xloader"
      pip install -U "requests[security]"
    fi
    
  fi
done

echo "📦 Loading plugins from ENV"
ckan config-tool $CKAN_INI "ckan.plugins = $CKAN__PLUGINS"

echo "⚙ Loading DEV DB / Solr settings"
ckan config-tool $CKAN_INI \
    "sqlalchemy.url = $CKAN_SQLALCHEMY_URL" \
    "ckan.datastore.write_url = $CKAN_DATASTORE_WRITE_URL" \
    "ckan.datastore.read_url = $CKAN_DATASTORE_READ_URL" \
    "solr_url = $CKAN_SOLR_URL" \
    "ckan.redis.url = $CKAN_REDIS_URL"

echo "🏗 Running prerun.py"
python3 prerun.py

echo "🌍 Starting CKAN Dev Server"

chmod -R 777 /srv/app/conf /srv/app/src_extensions

CKAN_RUN="/usr/local/bin/ckan -c $CKAN_INI run -H 0.0.0.0"
CKAN_OPTIONS=""
if [ "$USE_DEBUGPY_FOR_DEV" = true ] ; then
    CKAN_RUN="/usr/local/bin/python -m debugpy --listen 0.0.0.0:5678 $CKAN_RUN"
    CKAN_OPTIONS="$CKAN_OPTIONS --disable-reloader"
fi

if [ "$USE_HTTPS_FOR_DEV" = true ] ; then
    CKAN_OPTIONS="$CKAN_OPTIONS -C unsafe.cert -K unsafe.key"
fi

exec $CKAN_RUN $CKAN_OPTIONS