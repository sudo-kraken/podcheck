#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
fake_bin="${tmp_dir}/bin"
collector_dir="${tmp_dir}/collector"
log_file="${tmp_dir}/commands.log"
mkdir -p "$fake_bin" "$collector_dir"
trap 'rm -rf "$tmp_dir"' EXIT

cat > "${fake_bin}/curl" <<'CURL'
#!/usr/bin/env bash
range_end=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    -r)
      range_end="${2##*-}"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

printf '%s\n' 'VERSION="v1.2.2"'
if [[ "$range_end" -ge 512 ]]; then
  printf '%s\n' '# ChangeNotes: regression test fixture'
fi
CURL

cat > "${fake_bin}/regctl" <<'REGCTL'
#!/usr/bin/env bash
if [[ "${1:-}" == "version" ]]; then
  printf '%s\n' 'regctl fixture'
  exit 0
fi

image="${@: -1}"
digest="${REGCTL_DIGEST:-sha256:abc}"
printf '%s\n' "${image%@*}@${digest}"
REGCTL

cat > "${fake_bin}/jq" <<'JQ'
#!/usr/bin/env bash
if [[ "${1:-}" == "--version" ]]; then
  printf '%s\n' 'jq-1.6-fixture'
  exit 0
fi

if [[ "${1:-}" != "-r" ]]; then
  printf 'unsupported jq fixture call: %s\n' "$*" >&2
  exit 1
fi

query="$2"
input="$(cat)"
if [[ "$input" == "{}" ]]; then
  printf '%s\n' 'null'
  exit 0
fi

case "$query" in
  *'com.docker.compose.project.working_dir'*)
    sed -n 's/.*"working_dir":"\([^"]*\)".*/\1/p' <<< "$input"
    ;;
  *'com.docker.compose.project.config_files'*)
    sed -n 's/.*"config_files":"\([^"]*\)".*/\1/p' <<< "$input"
    ;;
  *'com.docker.compose.service'*)
    sed -n 's/.*"service":"\([^"]*\)".*/\1/p' <<< "$input"
    ;;
  *'com.docker.compose.project.environment_file'*)
    printf '%s\n' 'null'
    ;;
  *'sudo-kraken.podcheck.update'*)
    printf '%s\n' 'null'
    ;;
  *'sudo-kraken.podcheck.restart-stack'*)
    printf '%s\n' 'null'
    ;;
  *'sudo-kraken.podcheck.only-specific-container'*)
    sed -n 's/.*"only_specific":"\([^"]*\)".*/\1/p' <<< "$input"
    ;;
  *)
    printf '%s\n' 'null'
    ;;
esac
JQ

cat > "${fake_bin}/podman" <<'PODMAN'
#!/usr/bin/env bash
set -euo pipefail

log() {
  printf '%s\n' "$*" >> "${FAKE_PODMAN_LOG}"
}

extract_format() {
  local format=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --format|-f)
        format="$2"
        shift 2
        ;;
      *)
        shift
        ;;
    esac
  done
  printf '%s\n' "$format"
}

case "${1:-}" in
  info)
    exit 0
    ;;
  compose)
    shift
    if [[ "${1:-}" == "version" ]]; then
      exit 0
    fi
    printf 'compose' >> "${FAKE_PODMAN_LOG}"
    for arg in "$@"; do
      printf ' [%s]' "$arg" >> "${FAKE_PODMAN_LOG}"
    done
    printf '\n' >> "${FAKE_PODMAN_LOG}"
    exit 0
    ;;
  ps)
    log "ps $*"
    for container in ${FAKE_CONTAINERS}; do
      printf '%s\n' "$container"
    done
    exit 0
    ;;
  inspect)
    container="$2"
    format="$(extract_format "${@:3}")"
    case "$format" in
      *'json .Config.Labels'*)
        if [[ "${FAKE_COMPOSE_LABELS:-false}" == true ]]; then
          only_specific="null"
          if [[ "$container" == "svc-a" ]]; then
            only_specific="true"
          fi
          printf '{"working_dir":"%s","config_files":"compose.yml","service":"%s","only_specific":"%s"}\n' \
            "$FAKE_PROJECT_DIR" "$container" "$only_specific"
        else
          printf '%s\n' '{}'
        fi
        ;;
      *'.Config.Image'*)
        printf 'registry.example/%s:latest\n' "$container"
        ;;
      *'.Image}}'*)
        printf 'sha256:%s\n' "$container"
        ;;
      *'.State.Status'*)
        printf '%s\n' 'running'
        ;;
      *'PODMAN_SYSTEMD_UNIT'*)
        printf '%s\n' '<no value>'
        ;;
      *)
        printf '\n'
        ;;
    esac
    exit 0
    ;;
  image)
    if [[ "${2:-}" == "inspect" ]]; then
      image_id="${3#sha256:}"
      printf '[registry.example/%s:latest@sha256:abc]\n' "$image_id"
      exit 0
    fi
    ;;
  pull)
    log "pull $2"
    exit 0
    ;;
esac

printf 'unexpected podman call: %s\n' "$*" >&2
exit 1
PODMAN

chmod +x "${fake_bin}/curl" "${fake_bin}/regctl" "${fake_bin}/jq" "${fake_bin}/podman"

export PATH="${fake_bin}:${PATH}"
export FAKE_PODMAN_LOG="$log_file"
export FAKE_CONTAINERS="web db"

latest_snippet="$(curl --retry 3 --retry-delay 1 --connect-timeout 5 -sf -r 0-1024 "fixture")"
latest_changes="$(echo "${latest_snippet}" | sed -n "/ChangeNotes/s/# ChangeNotes: //p")"
[[ "$latest_changes" == "regression test fixture" ]]

: > "$log_file"
bash "${repo_root}/podcheck.sh" -n -c "$collector_dir" web,db > "${tmp_dir}/check.log"
grep -Fq 'name=^(web|db)$' "$log_file"
grep -Fq 'podcheck_total 2' "${collector_dir}/podcheck.prom"
grep -Fq 'podcheck_images_analyzed 2' "${collector_dir}/podcheck.prom"

project_dir="${tmp_dir}/project with spaces"
mkdir -p "$project_dir"
export FAKE_PROJECT_DIR="$project_dir"
export FAKE_COMPOSE_LABELS=true
export FAKE_CONTAINERS="svc-a svc-b"
export REGCTL_DIGEST="sha256:def"

: > "$log_file"
bash "${repo_root}/podcheck.sh" -y svc-a,svc-b > "${tmp_dir}/update.log"
grep -Fq "[-f] [${project_dir}/compose.yml]" "$log_file"
grep -Fq 'up] [-d] [--force-recreate] [svc-a]' "$log_file"
up_count="$(grep -F ' [up] ' "$log_file" | wc -l)"
svc_target_count="$(grep -F 'up] [-d] [--force-recreate] [svc-a]' "$log_file" | wc -l)"
if [[ "$up_count" -ne 2 ]] || [[ "$svc_target_count" -ne 1 ]]; then
  printf '%s\n' 'Specific container selection leaked into the next compose update' >&2
  exit 1
fi

printf '%s\n' 'podcheck regression tests passed'
