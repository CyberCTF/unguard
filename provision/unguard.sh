#!/bin/sh
# Deploys Unguard on the VM's k3s cluster the way upstream's chart README does: MariaDB from the
# Bitnami chart 11.5.7 (persistence off, image from bitnamilegacy, as upstream's README and
# skaffold.yaml set it), then the Unguard chart from the vendored source (unguard/chart/) with its
# default values (images ghcr.io/dynatrace-oss/unguard/*:0.24.0). Differences, and why:
# - The MariaDB chart is fetched as a file pinned by SHA-256 rather than from a Helm repository
#   (charts.bitnami.com now redirects to Broadcom and the repository may move again).
# - Upstream reaches the app through an ingress (host unguard.kube on minikube); here the envoy
#   proxy's ports 8080 (app, under /ui) and 8081 (health) are forwarded on the VM's address by a
#   systemd service, so the lab network reaches them without an ingress controller or a hosts entry.
set -eu
SRC=/opt/isoloom/unguard
HERE=/opt/isoloom/provision
MARIADB_CHART_SHA256=7b465fbc11e3511c48fdd42904a9acd3444203064bbc34d985d79f7d025ac8bb
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

if ! helm -n unguard status unguard-mariadb >/dev/null 2>&1; then
  curl -fsSL -o /tmp/mariadb-11.5.7.tgz https://charts.bitnami.com/bitnami/mariadb-11.5.7.tgz
  echo "$MARIADB_CHART_SHA256  /tmp/mariadb-11.5.7.tgz" | sha256sum -c -
  helm install unguard-mariadb /tmp/mariadb-11.5.7.tgz \
    --set primary.persistence.enabled=false \
    --set image.repository=bitnamilegacy/mariadb \
    --wait --timeout 15m --namespace unguard --create-namespace
  rm -f /tmp/mariadb-11.5.7.tgz
fi
helm -n unguard status unguard >/dev/null 2>&1 || \
  helm install unguard "$SRC/chart" --wait --timeout 30m --namespace unguard --create-namespace

install -m 755 "$HERE/unguard-access.sh" /usr/local/bin/unguard-access
cat > /etc/systemd/system/unguard-access.service <<UNIT
[Unit]
Description=Unguard's envoy proxy on ports 8080 and 8081
After=k3s.service
Wants=k3s.service

[Service]
ExecStart=/usr/local/bin/unguard-access
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now unguard-access.service
echo "Unguard deployed; the app answers on port 8080 under /ui"
