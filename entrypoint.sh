#!/bin/bash
cd /tmp/project
sudo chown ue4.ue4 /tmp/project -R
sudo chown ue4.ue4 /tmp/dist -R

# Start Building
ue4 package Shipping -platform=Android
sudo mv /tmp/project/dist/* /tmp/dist
echo "Build finished and files copied to dist folder"