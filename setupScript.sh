#!/usr/bin/env bash

git clone "https://github.com/powerpool-finance/powerpool-agent-v2-node.git"
pk=$1
worker=$2
pass=$3
rpc=$4
agent=$5
nname=$6

cd powerpool-agent-v2-node
npm install --global yarn
npm install --global typescript
sudo npm cache clean -f
sudo npm install -g n
sudo n stable
hash -r

yarn
tsc
DIR=dist node --loader ts-node/esm ./writeVersionData.ts
node jsongen.js $pk $pass
mv ./config/main.template.yaml ./config/main.yaml
printf "#!/usr/bin/env bash\n\nNETWORK_NAME=$6 NETWORK_RPC=$4 AGENT_ADDRESS=$5 KEEPER_WORKER_ADDRESS=$2 KEYPASSWORD=$3 ACCRUE_REWARDS='false' LOG_LEVEL='debug' APP_ENV='service' node $(pwd)/dist/Cli.js" > startupScript.sh
chmod a+x startupScript.sh
printf "[Unit]\nDescription=PowerAgent Noderunner\nWants=network-online.target\nAfter=network-online.target\n\n[Service]\nRestart=always\nExecStart=$(pwd)/startupScript.sh\n\n[Install]\nWantedBy=default.target" > /etc/systemd/system/PowerAgent.service
chmod 644 /etc/systemd/system/PowerAgent.service
systemctl enable --now PowerAgent.service


