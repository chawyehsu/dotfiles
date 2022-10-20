#!/bin/bash

IPFS_VERSION="0.16.0"
IPFS_UPDATE_VERSION="1.9.0"

wget https://dist.ipfs.tech/kubo/v${IPFS_VERSION}/kubo_v${IPFS_VERSION}_linux-amd64.tar.gz
tar -xzvf kubo_v${IPFS_VERSION}_linux-amd64.tar.gz
sudo ./kubo/install.sh && rm -rf kubo

wget https://dist.ipfs.tech/ipfs-update/v${IPFS_UPDATE_VERSION}/ipfs-update_v${IPFS_UPDATE_VERSION}_linux-amd64.tar.gz
tar -xzvf ipfs-update_v${IPFS_UPDATE_VERSION}_linux-amd64.tar.gz
sudo ./ipfs-update/install.sh && rm -rf ipfs-update

useradd -M -s /sbin/nologin ipfs
sudo cp ./ipfs/ipfs.service /etc/systemd/system/ipfs.service

# bash-completion
ipfs commands completion bash | sed 's/-o nosort//g' > ipfs-completion
sudo mv ipfs-completion /etc/bash_completion.d/ipfs-completion
