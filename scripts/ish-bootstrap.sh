#!/bin/sh
# This ish-bootstrap file is created by Chawye Hsu, licensed under the MIT license.

# Replce alpine repository url with TUNA mirror
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

# Download and install apk
wget -qO- 'http://mirrors.tuna.tsinghua.edu.cn/alpine/v3.12/main/x86/apk-tools-static-2.10.5-r1.apk' | tar -xz sbin/apk.static && ./sbin/apk.static add apk-tools && rm sbin/apk.static

# Install base packages
apk update
apk add bash bash-completion coreutils git nano

# Change the $SHELL from ash(1) to bash(1)
sed -i 's/\/bin\/ash/\/bin\/bash/g' /etc/passwd
