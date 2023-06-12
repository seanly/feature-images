#!/bin/bash

# install base tools

microdnf update -y
microdnf install epel-release -y 
microdnf install neovim procps net-tools telnet curl wget -y