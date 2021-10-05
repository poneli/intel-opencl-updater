#!/bin/bash
#### Description: Upgrades Intel OpenCL for debian/ubuntu based distros
####
#### Written by: poneli on 2021 October 3
#### Published on: https://github.com/poneli/
#### =====================================================================
#### <VARIABLES>
latestversion=$(curl -s -L https://github.com/intel/compute-runtime/releases | grep '<a href="/intel/compute-runtime/releases/tag/' | head -1 | cut -d '>' -f 2 | cut -d '<' -f 1)
currentversion=$(dpkg -s intel-opencl | awk '/^Version:/ { print $NF }')
packages=$(curl -s -L https://github.com/intel/compute-runtime/releases | grep -m2 -A 10 "snippet-clipboard-content position-relative" | awk '/wget/ {print $NF}' | awk '!x[$0]++')
downloadfolder="/change/me/example/directory" # No trailing slash
#### </VARIABLES>
if [[ $EUID -gt 0 ]]; then
	printf "Run with sudo... \n"
	exit
fi

if [[ $latestversion > $currentversion ]]; then
	printf "Downloading to %s... \n" "$downloadfolder"
	wget -q $packages -P $downloadfolder
	printf "Installing update... \n"
	dpkg -i $downloadfolder/*.deb &>/dev/null
	if [[ $(dpkg -s intel-opencl | awk '/^Version:/ { print $NF }') = $latestversion ]]; then
	  printf "Intel OpenCL updated successfully from version %s to %s... \n" "$currentversion" "$latestversion"
	  printf -- "%(%Y-%m-%d %H:%M:%S)T [SUCCESS] Intel OpenCL updated to %s... \n" "$(date +%s)" "$latestversion" | tee -a $downloadfolder/update.log >/dev/null
	  printf "Cleaning up %s... \n" "$downloadfolder"
	  rm -f $downloadfolder/*.deb
	else
	  printf "Installation of Intel OpenCL %s failed... \nTerminated... \n" "$latestversion"
	  printf -- "%(%Y-%m-%d %H:%M:%S)T [ERROR] Intel OpenCL %s update failed... \n" "$(date +%s)" "$latestversion" | tee -a $downloadfolder/update.log >/dev/null
	fi
else
	printf "Intel OpenCL %s is already installed... \nTerminated... \n" "$latestversion"
	printf -- "%(%Y-%m-%d %H:%M:%S)T [INFO] Intel OpenCL %s is already installed... \n" "$(date +%s)" "$latestversion" | tee -a $downloadfolder/update.log >/dev/null
fi
