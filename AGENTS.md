# Cluster API Provider Hetzner Cloud — Agent Guide

This document provides guidance for AI coding agents (GitHub Copilot, Codex,
Claude, etc.) working in this repository.

---

## Git Workflow — MANDATORY

- **Never commit changes** unless explicitly instructed to do so.
- **Never create a branch** unless explicitly instructed to do so.
- **Never open a pull request** unless explicitly instructed to do so.
- Leave all changes as unstaged working-tree modifications by default.

---

## Shell Environment

This repository uses [**mise**](https://mise.jdx.dev) (`mise.toml`) to provide
the required tooling.

**Always run bash commands through mise-managed tools.** After installing
mise and trusting the repo (`mise trust && mise install`), the tools defined
in `mise.toml` are available directly on `PATH` via mise's shims/activation,
so commands can be run as-is:

```bash
scripts/generate-template
yamllint .
```

If mise is not activated in your shell, prefix commands with `mise exec --`:

```bash
mise exec -- scripts/generate-template
mise exec -- yamllint .
```

Do **not** assume system-installed tools are correct or present. All managed
tools must be resolved through mise.

`mise.toml` provides:
- **clusterctl**
- **kubectl**
- **kubectl-slice** via the `github:patrickdappollonio/kubectl-slice` backend
- **yamlfmt**
- **yamllint**
- **yq**
- **pre-commit** (available if hooks are added again later)

`json-patch` v5.9.11 is still required by `scripts/generate-template`, but it
could not be resolved portably through a working mise backend in this
environment. Install it manually before regenerating the template, for example
with `go install github.com/evanphx/json-patch/v5/cmd/json-patch@v5.9.11`.

---

## Project Overview

This repository generates the published `template.yaml` for provisioning a Cluster API workload cluster on **Hetzner Cloud**. The final template keeps the standard kubeadm-based control plane, Hetzner infrastructure objects, remediation templates, and worker `MachineDeployment` resources for the `fsn1`, `nbg1`, and `hel1` failure domains.

---

## Repository Layout

```text
.github/workflows/      CI automation (testing, release, automerge)
patches/                RFC6902 JSON patches applied to each split manifest
  *.json                One patch file per generated resource basename
scripts/
  generate-template     Regenerates template.yaml from clusterctl output + patches
template.yaml           Published multi-document Cluster API template
README.md               Developer and usage documentation
mise.toml               Mise-managed toolchain definition
.yamllint               YAML lint rules used by CI
AGENTS.md               Primary AI agent instructions
CLAUDE.md               Reference to AGENTS.md
GEMINI.md               Reference to AGENTS.md
```

---

## Template Authoring / Key Patterns

- `scripts/generate-template` starts from `clusterctl generate cluster dummy --infrastructure hetzner:v1.0.6` and writes the upstream output into a temporary `processing/` directory.
- The generated multi-document YAML is split with `kubectl slice`; each split file is then patched by the same-named JSON patch from `patches/` via `json-patch`.
- Every split manifest is formatted with `yamlfmt`, wrapped with `---` / `...`, then concatenated back into the root `template.yaml`.
- The `machinedeployment-fsn1.yaml` output is the source for the additional `nbg1` and `hel1` worker deployments, created by copying and retargeting the failure domain.

---

## Linting and Validation

The primary validation flow is:

```bash
scripts/generate-template
yamllint .
```

CI runs those same checks from `.github/workflows/testing.yml`.
There is no Taskfile or broader compiled test suite in this repository.

---

## CI / GitHub Actions

| Workflow | Trigger | Purpose |
|---|---|---|
| `testing.yml` | `workflow_dispatch`, push to `master`, pull requests to `master` | Sets up mise, regenerates `template.yaml`, and runs `yamllint .` |
| `release.yml` | `workflow_dispatch`, weekly cron (`0 8 * * 1`) | Runs semantic-release and commits the `.github/RELEASE` build timestamp update |
| `automerge.yml` | `workflow_dispatch`, pull requests to `master` | Auto-approves and enables auto-merge for Dependabot pull requests |

---

## Git & Contribution Conventions

- Commit messages should follow **Conventional Commits**; valid types are
  defined in `.github/semantic.yml`.
- PRs are **squash-merged** (confirmed via `.github/settings.yml`).
- Releases are automated via **semantic-release** (see
  `.github/workflows/release.yml` for the weekly schedule).
- Security issues → email `security@cloudhippie.de` before opening a public
  issue.

---

## Key Patterns to Follow

1. **Regenerate, do not handcraft**: when the upstream Hetzner Cluster API output changes, update `scripts/generate-template` and `patches/*.json`, then regenerate `template.yaml` instead of manually editing the assembled file.
2. **Keep patch/file name parity**: every JSON patch is matched by basename (`patches/<name>.json` ↔ generated `<name>.yaml`). Preserve that convention when adding or renaming resources.
3. **Use placeholders, not environment-specific literals**: the published template must keep `${...}` variables such as `${CLUSTER_NAME}`, `${KUBERNETES_VERSION}`, and machine types intact for downstream consumers.
4. **Treat `machinedeployment-fsn1.yaml` as the canonical worker template**: the `nbg1` and `hel1` documents are derived copies, so structural worker changes should start from the `fsn1` version.
5. **Preserve Hetzner-specific control-plane and remediation resources**: this repo intentionally keeps kubeadm control-plane manifests and both remediation templates in the generated output.

---

## Metadata Changes

When updating `AGENTS.md`, `GEMINI.md`, and `CLAUDE.md`, treat `AGENTS.md` as
the primary instructions file, and `GEMINI.md`/`CLAUDE.md` as copies that
simply reference it (`@AGENTS.md`).

These files are collectively called the "agent instruction files".
