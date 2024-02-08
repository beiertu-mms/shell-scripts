#!/usr/bin/env bash
#===============================================================================
#
#          FILE: system-update.sh
#
#         USAGE: ./system-update.sh
#
#   DESCRIPTION: Check and update programs on system.
#
#  REQUIREMENTS: curl,git,go,jq,yay
#        AUTHOR: tung beier
#       CREATED: 28 May 2021 20:29 CEST
#===============================================================================

set -o errexit # Exit when a command fails
# Use || true if a command is allowed to fail
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

function print() {
  echo -e "\n${GREEN:-}${1}${NC:-}\n"
}

function warn() {
  echo -e "\n${YELLOW:-}${1}${NC:-}\n"
}

function error() {
  echo -e "\n${RED:-}${1}${NC:-}\n"
}

function update_gcloud() {
  if ! command -v gcloud &>/dev/null; then
    echo "gcloud is not installed on the system."
    echo "install guide: https://cloud.google.com/sdk/docs/install"
    return
  fi

  print "update gcloud"
  gcloud components update
}

function update_confluent_cli() {
  if ! command -v confluent &>/dev/null; then
    echo "confluent is not installed on the system."
    echo "install guide: https://docs.confluent.io/confluent-cli/current/install.html"
    return
  fi

  print "update confluent"
  confluent update

  echo "update confluent completion"
  confluent completion zsh >~/.config/zsh/completion/_confluent
}

function update_zsh_plugins() {
  print "update zsh plugins"
  for zsh_plugin_dir in "$HOME"/.local/share/zsh/plugins/*; do
    [[ -d "${zsh_plugin_dir}/.git" ]] || continue

    (
      echo "updating ${zsh_plugin_dir##/} ..."
      cd "$zsh_plugin_dir"
      git pull --ff-only
    )
  done

  curl -LJO https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/ssh-agent/ssh-agent.plugin.zsh \
    --output-dir "$HOME/.local/share/zsh/plugins/ssh-agent/"
}

function update_cheatsheets() {
  print "update cheatsheets"
  go install github.com/cheat/cheat/cmd/cheat@latest
  for d in $(cheat -d | awk '{print $2}'); do
    echo "update $d"
    cd "$d"
    [[ -d ".git" ]] && git pull || echo 'no-doing'
  done
}

function update_k8s_kind() {
  print "update k8s kind"
  go install sigs.k8s.io/kind@latest

  echo "update kind completion"
  kind completion zsh >"$HOME/.config/zsh/completion/_kind"
}

function update_pet() {
  print "update pet"
  go install github.com/knqyf263/pet@latest
}

function update_ktlint() {
  local latest_url="https://api.github.com/repos/pinterest/ktlint/releases/latest"
  local current_version
  current_version=$(ktlint --version)
  local latest_version
  latest_version=$(curl -s -H "Accept: application/vnd.github.v3+json" "$latest_url" | jq -r '.tag_name')

  if [[ "$current_version" != "$latest_version" ]]; then
    local dl_dir="$HOME/downloads"

    # TODO verify download
    curl "https://github.com/pinterest/ktlint/releases/download/${latest_version}/ktlint" \
      --show-error --location --remote-name --output-dir "$dl_dir"
    chmod a+x "${dl_dir}/ktlint"
    mv -u "${dl_dir}/ktlint" "$HOME/.local/bin/ktlint"
  fi
}

function update_docker_compose() {
  if ! command -v docker compose version &>/dev/null; then
    warn "docker compose plugin is not installed"
    echo "See https://docs.docker.com/compose/install/linux/#install-the-plugin-manually for installation instruction"
    return
  fi

  print "update docker compose plugin"
  local latest_url="https://api.github.com/repos/docker/compose/releases/latest"
  local current_version
  current_version=$(docker compose version | cut -d' ' -f4)
  local latest_version
  latest_version=$(curl -s -H "Accept: application/vnd.github.v3+json" "$latest_url" | jq -r '.tag_name')

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "docker compose is up-to-date (version = $current_version)"
    return
  fi

  local docker_compose="$HOME/downloads/docker-compose"
  curl --location --show-error \
    "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-linux-x86_64" \
    --output "$docker_compose"

  local checksum_file="$HOME/downloads/checksum.txt"
  curl --location --show-error \
    "https://github.com/docker/compose/releases/download/${latest_version}/checksums.txt" \
    --output "$checksum_file"

  if grep -q "$(sha256sum "$docker_compose" | cut -d' ' -f1)" "$checksum_file"; then
    chmod +x "$docker_compose"
    mv "$docker_compose" "${DOCKER_CONFIG:-~/.docker}/cli-plugins/docker-compose"
  else
    error "downloaded docker compose file does not match the checksum"
  fi
}

function update_detekt() {
  if ! command -v detekt &>/dev/null; then
    warn "detekt is not installed"
    echo "See https://github.com/detekt/detekt for installation instruction"
    return
  fi

  print "update detekt"
  local latest_url="https://api.github.com/repos/detekt/detekt/releases/latest"
  local current_version
  current_version=$(detekt --version)
  local latest_tag
  local latest_version
  latest_tag=$(curl -s -H "Accept: application/vnd.github.v3+json" "$latest_url" | jq -r '.tag_name')
  latest_version="${latest_tag#v}"

  if [[ "$current_version" == "$latest_version" ]]; then
    echo "detekt is up-to-date (version = $current_version)"
    return
  fi

  local detekt_zip="$HOME/downloads/detekt.zip"
  curl --location --show-error \
    "https://github.com/detekt/detekt/releases/download/${latest_tag}/detekt-cli-${latest_version}.zip" \
    --output "$detekt_zip"

  unzip "$detekt_zip" -d "$HOME/downloads/"
  mv -v "$HOME/downloads/detekt-cli-$latest_version" "$HOME/.local/share/detekt/${latest_tag}/"

  mkdir -vp "$HOME/.local/share/detekt/${latest_tag}/plugins"
  curl --location --show-error \
    "https://github.com/detekt/detekt/releases/download/${latest_tag}/detekt-formatting-${latest_version}.jar" \
    --output "$HOME/.local/share/detekt/${latest_tag}/plugins/detekt-formatting.jar"

  ln -sf "$HOME/.local/share/detekt/$latest_tag/bin/detekt-cli" "$HOME/.local/bin/detekt"
  ln -sf "$HOME/.local/share/detekt/$latest_tag/plugins/detekt-formatting.jar" "$HOME/.local/share/detekt/formatting.jar"
}

function update_arch() {
  print "update arch"
  yay -Syyu
}

# ----- Script run -----
print "Start system update..."

update_gcloud
update_confluent_cli
update_zsh_plugins
update_cheatsheets
update_k8s_kind
update_pet
update_ktlint
update_insomnia
update_docker_compose
update_detekt
update_arch

print "Finished"
