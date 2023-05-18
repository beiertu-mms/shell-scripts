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

function update_insomnia() {
  print "update insomnia"

  local -r releases_url="https://api.github.com/repos/Kong/insomnia/releases?per_page=2"
  local -r latest_version=$(curl -s -H "Accept: application/vnd.github.v3+json" "$releases_url" |
    jq -r '.[] | select(.prerelease = "false") | select(.name | startswith("Insomnia")) | .tag_name')

  local -r state_folder=$HOME/.local/state/insomnia/
  [ ! -d "$state_folder" ] && mkdir -p "$state_folder"

  local -r version_file=$state_folder/version.txt
  [ ! -f "$version_file" ] && touch "$version_file"

  local -r version="${latest_version#core@}"

  if grep -q "$version" "$version_file"; then
    echo "insomnia is up-to-date"
  else
    local -r dl_dir="$HOME/downloads"
    curl --location \
      --remote-header-name \
      --remote-name \
      --output-dir "$dl_dir" \
      "https://github.com/Kong/insomnia/releases/download/core%40${version}/Insomnia.Core-${version}.tar.gz"
    tar -xzf "${dl_dir}/Insomnia.Core-${version}.tar.gz" -C "${dl_dir}"
    rsync -auv "${dl_dir}/Insomnia.Core-${version}/" "$HOME/.local/share/insomnia/"
    echo "$version" >"$version_file"
  fi
}

function update_docker_compose() {
  if command -v docker compose version &>/dev/null; then
    print "update docker compose plugin"
    # https://docs.docker.com/compose/install/linux/#install-the-plugin-manually
    local latest_url="https://api.github.com/repos/docker/compose/releases/latest"
    local current_version
    current_version=$(docker compose version | cut -d' ' -f4)
    local latest_version
    latest_version=$(curl -s -H "Accept: application/vnd.github.v3+json" "$latest_url" | jq -r '.tag_name')

    if [[ "$current_version" != "$latest_version" ]]; then
      local output="$HOME/downloads/docker-compose"

      # TODO verify download
      curl "https://github.com/docker/compose/releases/download/${latest_version}/docker-compose-linux-x86_64" \
        --output "$output"
      chmod +x "$output"
      doas mv "$output" /usr/local/lib/docker/cli-plugins/docker-compose
    fi
  fi
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
update_arch

print "Finished"