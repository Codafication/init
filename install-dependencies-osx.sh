#!/bin/bash
echo
echo '### Installing nvm ###'
echo
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
echo "NVM installed: $(nvm --version)"

echo
echo '### Installing Node.js v12 ###'
echo
nvm install 12
echo "Node installed: $(node -v)"

echo
echo '### Installing roomservice ###'
echo
curl -L https://github.com/curtiswilkinson/roomservice-rust/releases/download/v4.0.1/x86_64-apple-darwin.tar.gz | tar xz
 
cp target/x86_64-apple-darwin/roomservice /usr/local/bin && rm -rf target roomservice.tar.gz

echo
echo '### Install Node.js packages ###'
echo
yarn install

echo
echo "Please log out or reboot for your new permission group to enumerate."
echo
read -p "Press [Enter] key to continue..."