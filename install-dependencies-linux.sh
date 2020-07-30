#!/bin/bash

echo
echo '### Installing Operating System Dependencies ###'
echo
wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

wget -q -O - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

sudo apt update
sudo apt install -y apt-transport-https \
  build-essential \
  ca-certificates \
  curl \
  docker-ce \
  firefox \
  lolcat \
  openssl \
  software-properties-common \
  yarn

sudo apt autoremove -y

sudo usermod -aG docker ${USER}
echo "docker installed: $(sudo docker --version)"
echo "yarn installed: $(yarn --version)"

cd /tmp
pwd

echo '### Installing Chrome ###'
sudo wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O /tmp/chrome.deb
sudo dpkg -i /tmp/chrome.deb

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
echo '### Login to NPM ###'
echo
echo 'Press CTRL+C to cancel NPM login, the script will continue'
echo
npm login

echo
echo '### Installing roomservice ###'
echo
curl -L https://github.com/curtiswilkinson/roomservice-rust/releases/download/v4.0.0/x86_64-unknown-linux-musl.tar.gz | tar xz
sudo cp target/x86_64-unknown-linux-musl/roomservice /usr/local/bin && rm -rf target roomservice.tar.gz

echo
echo '### Installing AWS CLI ###'
echo
mkdir /tmp/awscli
cd /tmp/awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
aws --version
aws configure
cd /tmp
rm -rf /tmp/awscli

echo
echo '### Installing kubectl ###'
echo
cd /tmp
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo "kubectl installed: $(kubectl version --client)"
cd

echo
echo '### Installing eksctl ###'
echo
curl --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
eksctl version

echo
echo '### Installing aws-iam-authenticator ###'
echo
cd /tmp
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator
echo "aws-iam-authenticator installed: $(aws-iam-authenticator version)"

echo
echo '### Install Node.js packages ###'
echo
yarn install

echo
echo '### Install microk8s ###'
echo
sudo snap install microk8s --classic --channel=1.18/stable
sudo usermod -a -G microk8s $USER

echo "--service-node-port-range=80-32767" | sudo tee -a /var/snap/microk8s/current/args/kube-apiserver
echo "microk8s: Restarting snap.microk8s.daemon-apiserver"
sudo systemctl restart snap.microk8s.daemon-apiserver

echo "microk8s: Waiting for ready status"
sudo microk8s status --wait-ready
echo "microk8s: Get nodes - just for fun!"
sudo microk8s kubectl get nodes

echo "microk8s: Enabling add-ons"
sudo microk8s enable dns
sudo microk8s enable dashboard
sudo microk8s enable registry

echo "microk8s: Creating ~/.kube/microk8s.config"
sudo microk8s kubectl config view --raw >$HOME/.kube/microk8s.config

echo
echo "Please add the following to your ~/.bashrc or equivalent:"
echo
echo '****************************************************************'
echo 'export KUBECONFIG=$HOME/.kube/config:$HOME/.kube/microk8s.config'
echo '****************************************************************'
echo
read -p "Press [Enter] key to continue..."

echo '### Installing VS Code ###'
sudo snap install --classic code

echo '### Installing VS Extensions ###'
/usr/bin/code --install-extension esbenp.prettier-vscode
/usr/bin/code --install-extension foxundermoon.shell-format
/usr/bin/code --install-extension huizhou.githd
/usr/bin/code --install-extension letrieu.expand-region
/usr/bin/code --install-extension mechatroner.rainbow-csv
/usr/bin/code --install-extension mhutchie.git-graph
/usr/bin/code --install-extension mitchdenny.ecdc
/usr/bin/code --install-extension netcorext.uuid-generator
/usr/bin/code --install-extension Tyriar.sort-lines
/usr/bin/code --install-extension wmaurer.change-case

echo '### Installing Azure CLI ###'
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
echo '### Logging in to the Azure CLI ###'
/usr/bin/az login

echo
echo "Please log out or reboot for your new permission group to enumerate."
echo
read -p "Press [Enter] key to continue..."
