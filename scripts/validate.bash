#!/bin/bash
#This is the "After plan" script that validates and formats Terraform

#Setting color variables for outputs
green='\033[0;32m'
clear='\033[0m'
red='\033[0;31m'

echo -e "\n${green}Validating and fixing the formatting of your Terraform...${clear}\n"
terraform init && terraform fmt && terraform validate

rc=$?
if [[ $rc != 0 ]]; then
    echo -e "\n${red}Please fix the Terraform issues identified above, then re-run the Scalr pipeline.${clear}\n";
  else 
    echo -e "\n${green}Terraform checks passed successfully!${clear}\n"
  fi
