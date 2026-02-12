#!/bin/sh
set -e

echo "🔍 Checking CKAN config at ${CKAN_INI}"

if [ ! -f "${CKAN_INI}" ]; then
  echo "📝 ckan.ini not found, generating..."
  ckan generate config "${CKAN_INI}"

  # ckan config-tool "${CKAN_INI}" \
  #   "ckan.site_url = http://localhost:5000" \
  #   "ckan.plugins = image_view text_view recline_view datastore envvars" \

  echo "✅ ckan.ini generated at ${CKAN_INI}"
else
  echo "✅ ckan.ini already exists"
fi

exec "$@"
