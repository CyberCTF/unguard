# Upstream

| Dir | Repository | Version | Commit | Licence |
| --- | --- | --- | --- | --- |
| unguard | https://github.com/dynatrace-oss/unguard | v0.24.0 | dae142003e3a29238750bb7964255c4d3271fe2a | Apache-2.0 |

`unguard/` is that release, unchanged, without its Git history. Its Helm chart (`unguard/chart/`)
is installed as is; the service images are the ones upstream publishes for this release
(`ghcr.io/dynatrace-oss/unguard/*:0.24.0`, built from `unguard/src/`). MariaDB comes from the
Bitnami chart 11.5.7 upstream's README names, pinned by checksum in `provision/unguard.sh`. To
update, replace `unguard/` with a newer release, then this table.
