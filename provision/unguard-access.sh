#!/bin/sh
# Forwards Unguard's entry point (the envoy proxy) to the VM's address, restarted when it ends
# (a pod restart ends a port-forward).
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
while :; do
  kubectl -n unguard port-forward svc/unguard-envoy-proxy --address 0.0.0.0 8080:8080 8081:8081 >/dev/null 2>&1
  sleep 2
done
