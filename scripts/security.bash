#!/bin/bash
#This is the "Before plan" script that scans for security & compliance violations

#Setting color variables for outputs
green='\033[0;32m'
clear='\033[0m'
red='\033[0;31m'

#Downloading the latest version of Regula
wget -c -nv https://github.com/$(wget -nv \
https://github.com/fugue/regula/releases/latest -O - | \
egrep '/.*/.*/.*_Linux_x86_64.tar.gz' -o)

#Extracting Regula
tar -zxf *_Linux_x86_64.tar.gz regula

#Scanning for CIS Benchmark security and compliance violations
echo -e "\n${green}Scanning the security and compliance of your Terraform against CIS Benchmarks with Regula...${clear} \n"
cd ../
./regula run --include waivers.rego

rc=$?
if [[ $rc != 0 ]]; then
    echo -e "\n${red}Please fix your security and compliance violations, then re-run the Scalr pipeline.${clear}\n"; exit 1
  else 
    echo -e "\n${green}Security and compliance check passed successfully! Moving on to the next step in the Scalr pipeline.${clear}\n"
    #(Optional) Send results of security and compliance scan to Fugue UI
    #./regula run --sync --upload; exit 0
    ./regula run; exit 0
  fi
