#!/bin/bash

PROFILE_NAME="base-user"
ACC_KEY_ID=$(terraform output -raw acc_key_id)
SEC_ACC_KEY=$(terraform output -raw sec_acc_key)

aws configure set region "us-west-2" --profile $PROFILE_NAME
aws configure set output "json" --profile $PROFILE_NAME
aws configure set aws_access_key_id $ACC_KEY_ID --profile $PROFILE_NAME
aws configure set aws_secret_access_key $SEC_ACC_KEY --profile $PROFILE_NAME