#!/bin/bash

echo ">>> Running initial upgrade..."
sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove

echo ">>> Installing basic tools..."
sudo apt install -y make git

echo ">>> Creating custom directories..."
mkdir -p ~/dev ~/tmp
