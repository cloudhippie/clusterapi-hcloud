# ClusterAPI: Hetzner Cloud

[![Testing Build](https://github.com/cloudhippie/clusterapi-hcloud/actions/workflows/testing.yml/badge.svg)](https://github.com/cloudhippie/clusterapi-hcloud/actions/workflows/testing.yml)

This repository generates and defines a template for ClusterAPI.

## Usage

TBD

## Development

We are using [Nix][nix] to install all required tools automatically. If you
don't use [Nix][nix] it is up to you to install all required tools:

* [clusterctl][clusterctl]
* [kubectl-slice][slice]
* [json-patch][jsonpatch]
* [yamlfmt][yamlfmt]

If you got [Nix][nix] available on your system you can easily use
[Direnv][direnv] to get started with all the required tools:

```console
cat << EOF >| .envrc
use flake . --impure
EOF

direnv allow
```

After the installation of the required tools you should be able to execute the
script to generate a new template:

```console
scripts/generate-template
```

## Security

If you find a security issue please contact
[security@cloudhippie.de](mailto:security@cloudhippie.de) first.

## Contributing

Fork -> Patch -> Push -> Pull Request

## Authors

-   [Thomas Boerger](https://github.com/tboerger)

## License

Apache-2.0

## Copyright

```console
Copyright (c) 2025 Cloudhippie <info@cloudhippie.de>
```

[nix]: https://nixos.org/
[direnv]: https://direnv.net/
[clusterctl]: https://github.com/kubernetes-sigs/cluster-api
[slice]: https://github.com/patrickdappollonio/kubectl-slice
[jsonpatch]: https://github.com/evanphx/json-patch
[yamlfmt]: https://github.com/google/yamlfmt
