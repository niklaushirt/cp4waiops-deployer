#!/bin/sh
set -eu

echo "*****************************************************************************************************************************"
echo "*****************************************************************************************************************************"
echo "       ________  __  ___     ___    ________       "
echo "      /  _/ __ )/  |/  /    /   |  /  _/ __ \____  _____"
echo "      / // __  / /|_/ /    / /| |  / // / / / __ \/ ___/"
echo "    _/ // /_/ / /  / /    / ___ |_/ // /_/ / /_/ (__  ) "
echo "   /___/_____/_/  /_/    /_/  |_/___/\____/ .___/____/  "
echo "                                         /_/"
echo ""
echo "*****************************************************************************************************************************"
echo " 🐥 CloudPak for Watson AIOPs - Tool Container"
echo "*****************************************************************************************************************************"
echo "  "
echo ""
echo ""


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   📥  Fix Sudo"
# We do this first to ensure sudo works below when renaming the user.
# Otherwise the current container UID may not exist in the passwd database.
eval "$(fixuid -q)"

if [ "${DOCKER_USER-}" ]; then
  USER="$DOCKER_USER"
  if [ "$DOCKER_USER" != "$(whoami)" ]; then
    echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null
    # Unfortunately we cannot change $HOME as we cannot move any bind mounts
    # nor can we bind mount $HOME into a new home as that requires a privileged container.
    sudo usermod --login "$DOCKER_USER" coder
    sudo groupmod -n "$DOCKER_USER" coder

    sudo sed -i "/coder/d" /etc/sudoers.d/nopasswd
  fi
fi

# Allow users to have scripts run on container startup to prepare workspace.
# https://github.com/coder/code-server/issues/5177
if [ -d "${ENTRYPOINTD}" ]; then
  find "${ENTRYPOINTD}" -type f -executable -print -exec {} \;
fi


echo "   ------------------------------------------------------------------------------------------------------------------------------"
echo "   🚀  Installing Extensions"
code-server --install-extension ms-python.python
code-server --install-extension hookyqr.beautify
code-server --install-extension esbenp.prettier-vscode
code-server --install-extension ms-azuretools.vscode-docker
code-server --install-extension redhat.vscode-yaml
code-server --install-extension codezombiech.gitignore
code-server --install-extension pkief.material-icon-theme
code-server --install-extension eamodio.gitlens
code-server --install-extension ms-vscode-remote.remote-ssh
code-server --install-extension ms-vscode.remote-explorer
code-server --install-extension ms-vscode-remote.remote-ssh-edit
code-server --install-extension qwtel.sqlite-viewer
code-server --install-extension esbenp.prettier-vscode
code-server --install-extension chouzz.vscode-better-align
code-server --install-extension byi8220.indented-block-highlighting
code-server --install-extension ms-vscode-remote.remote-containers
code-server --install-extension ryu1kn.partial-diff
code-server --install-extension adityavm.vscode-monokai-seti
code-server --install-extension tuxtina.json2yaml
code-server --install-extension ahebrank.yaml2json
code-server --install-extension shakram02.bash-beautify
code-server --install-extension dcasella.monokai-plusplus

echo "*****************************************************************************************************************************"
echo " ✅ READY"
echo "*****************************************************************************************************************************"



exec dumb-init /usr/bin/code-server "$@"
