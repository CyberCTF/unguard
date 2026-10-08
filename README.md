# Unguard

[Unguard](https://github.com/dynatrace-oss/unguard) by Dynatrace: an insecure cloud-native
microservices demo application, a Twitter clone of about a dozen services written in Java,
.NET, Go, PHP, Python and Node.js, with server-side request forgery, command and SQL injection,
JWT key confusion, remote code execution and more. Unguard is built for Kubernetes (its status
service reads the cluster's API, two services run under their own service accounts), so this
repository runs it with [Isoloom](https://www.isoloom.com) as a cluster:
[`isoloom.yml`](isoloom.yml) describes one VM running single-node [k3s](https://k3s.io)
([`provision/k3s.sh`](provision/k3s.sh)), on which upstream's Helm chart, vendored unchanged with
the whole source in [`unguard/`](unguard), is installed as upstream's chart README says
([`provision/unguard.sh`](provision/unguard.sh)).

| Machine | Services |
| --- | --- |
| unguard | SSH 22 (kubectl on the cluster), the app through its envoy proxy on 8080 (`/ui`), the proxy's health endpoint on 8081 |

## Run it

```bash
isoloom run vagrant
isoloom test vagrant
```

Then open `http://10.60.124.10:8080/ui` from a machine of the lab network. The first start takes
about 20 minutes (copying the 900 MB source into the VM, k3s, then the service images). 6 GB of
memory for the machine, plus 1 GB for the controller that runs the checks.

Differences from upstream's own installation:

- Upstream develops on minikube or kind and reaches the app through an ingress (host
  `unguard.kube`); here the cluster is k3s v1.36.5 (pinned by checksum, Helm v3.22.0) and the
  envoy proxy's ports are forwarded on the VM's address by a systemd service.
- MariaDB comes from the Bitnami chart 11.5.7 with the `bitnamilegacy/mariadb` image, as
  upstream's README says, but the chart is fetched as a file pinned by checksum rather than
  through `helm repo add`.
- The service images are the ones upstream publishes for release 0.24.0 (what its chart names);
  they are not rebuilt from `unguard/src/`.

The optional parts of the chart stay off, as upstream's defaults have them: the RAG service and
its Ollama model, tracing, the malicious load generator. The user simulator (a headless browser
every three minutes) stays on, as upstream's default.

Lab guide: upstream's [exploit toolkit](unguard/exploit-toolkit/exploits/README.md), one
write-up per vulnerability. Upstream version and commit: [UPSTREAM.md](UPSTREAM.md).

## Licence

Apache-2.0, as Unguard ([LICENSE](LICENSE)), copyright Dynatrace LLC. The cluster runs k3s
(Apache-2.0), MariaDB (GPL-2.0, Bitnami's image) and Redis 5 (BSD-3-Clause). The application is
deliberately insecure: keep it isolated.
