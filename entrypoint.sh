#!/bin/bash
cd /tmp/project
sudo chown ue4.ue4 /tmp/project/dist -R

# Start Building
ue4 package Shipping -platform=Android
echo "Build finished"