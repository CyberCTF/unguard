#!/bin/sh
# Unguard's own services answer behind the envoy proxy: the frontend names itself, the ad
# service serves its ad page, and the proxy's health endpoint (itself vulnerable: it passes
# `path` to curl in a shell) reports the frontend healthy.
set -u
get() { curl -sS -L --max-time 30 "$1" 2>/dev/null; }
get http://unguard:8080/ui | grep -qi "unguard" || { echo "frontend"; exit 1; }
[ "$(curl -s -o /dev/null --max-time 30 -w '%{http_code}' http://unguard:8080/ad-service/ad)" = 200 ] || { echo "ad service"; exit 1; }
get "http://unguard:8081/healthz?path=http://localhost:8080/ui" | grep -q HEALTHY || { echo "envoy health"; exit 1; }
echo "frontend, ad service and envoy health answer"
