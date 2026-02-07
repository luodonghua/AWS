#!/bin/bash

set -e

REGION="${AWS_REGION:-us-east-1}"
VPC_NAME="MMA-vpc"
SG_NAME="MMA-RDS-SG"
VPN_CIDR="10.2.0.0/22"
CONFIG_FILE="mma-vpn-config.ovpn"
STATE_FILE=".vpn-state"

create_vpn() {
  echo "Setting up AWS Client VPN for $VPC_NAME..."

  VPC_ID=$(aws ec2 describe-vpcs --region $REGION \
    --filters "Name=tag:Name,Values=$VPC_NAME" \
    --query 'Vpcs[0].VpcId' --output text)
  [ "$VPC_ID" == "None" ] && echo "Error: VPC not found" && exit 1
  echo "VPC: $VPC_ID"

  SG_ID=$(aws ec2 describe-security-groups --region $REGION \
    --filters "Name=group-name,Values=$SG_NAME" "Name=vpc-id,Values=$VPC_ID" \
    --query 'SecurityGroups[0].GroupId' --output text)
  [ "$SG_ID" == "None" ] && echo "Error: Security Group not found" && exit 1
  echo "Security Group: $SG_ID"

  SUBNET_IDS=$(aws ec2 describe-subnets --region $REGION \
    --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=*public*" \
    --query 'Subnets[*].SubnetId' --output text)
  [ -z "$SUBNET_IDS" ] && echo "Error: No public subnets found" && exit 1
  SUBNET_ARRAY=($SUBNET_IDS)

  echo "Generating certificates with easy-rsa..."
  
  # Set local PKI directory
  export EASYRSA_PKI="$PWD/pki"
  
  # Initialize PKI
  EASYRSA_BATCH=1 easyrsa init-pki >/dev/null 2>&1
  
  # Build CA without prompts
  EASYRSA_BATCH=1 easyrsa build-ca nopass >/dev/null 2>&1
  
  # Generate server cert with SAN
  EASYRSA_BATCH=1 easyrsa --san=DNS:server build-server-full server nopass >/dev/null 2>&1
  
  # Generate client cert
  EASYRSA_BATCH=1 easyrsa build-client-full client1.domain.tld nopass >/dev/null 2>&1
  
  # Copy certs to working directory
  cp pki/ca.crt ca.crt
  cp pki/issued/server.crt server.crt
  cp pki/private/server.key server.key
  cp pki/issued/client1.domain.tld.crt client.crt
  cp pki/private/client1.domain.tld.key client.key
  
  SERVER_CERT_ARN=$(aws acm import-certificate --region $REGION \
    --certificate fileb://server.crt \
    --private-key fileb://server.key \
    --certificate-chain fileb://ca.crt \
    --query 'CertificateArn' --output text)

  CLIENT_CERT_ARN=$(aws acm import-certificate --region $REGION \
    --certificate fileb://client.crt \
    --private-key fileb://client.key \
    --certificate-chain fileb://ca.crt \
    --query 'CertificateArn' --output text)

  echo "Creating VPN endpoint..."
  VPN_ENDPOINT_ID=$(aws ec2 create-client-vpn-endpoint --region $REGION \
    --client-cidr-block $VPN_CIDR \
    --server-certificate-arn $SERVER_CERT_ARN \
    --authentication-options Type=certificate-authentication,MutualAuthentication={ClientRootCertificateChainArn=$CLIENT_CERT_ARN} \
    --connection-log-options Enabled=false \
    --split-tunnel \
    --security-group-ids $SG_ID \
    --vpc-id $VPC_ID \
    --tag-specifications "ResourceType=client-vpn-endpoint,Tags=[{Key=Name,Value=MMA-VPN}]" \
    --query 'ClientVpnEndpointId' --output text)

  echo "VPN_ENDPOINT_ID=$VPN_ENDPOINT_ID" > $STATE_FILE
  echo "Waiting for endpoint..."
  sleep 30

  for SUBNET_ID in ${SUBNET_ARRAY[@]:0:2}; do
    aws ec2 associate-client-vpn-target-network --region $REGION \
      --client-vpn-endpoint-id $VPN_ENDPOINT_ID --subnet-id $SUBNET_ID >/dev/null
  done

  echo "Waiting for endpoint to become available..."
  while true; do
    STATE=$(aws ec2 describe-client-vpn-endpoints --region $REGION \
      --client-vpn-endpoint-ids $VPN_ENDPOINT_ID \
      --query 'ClientVpnEndpoints[0].Status.Code' --output text)
    [ "$STATE" == "available" ] && break
    echo "Current state: $STATE"
    sleep 10
  done

  VPC_CIDR=$(aws ec2 describe-vpcs --region $REGION --vpc-ids $VPC_ID \
    --query 'Vpcs[0].CidrBlock' --output text)
  aws ec2 authorize-client-vpn-ingress --region $REGION \
    --client-vpn-endpoint-id $VPN_ENDPOINT_ID \
    --target-network-cidr $VPC_CIDR --authorize-all-groups >/dev/null

  aws ec2 export-client-vpn-client-configuration --region $REGION \
    --client-vpn-endpoint-id $VPN_ENDPOINT_ID --output text > $CONFIG_FILE

  echo "<cert>" >> $CONFIG_FILE
  cat client.crt >> $CONFIG_FILE
  echo "</cert>" >> $CONFIG_FILE
  echo "<key>" >> $CONFIG_FILE
  cat client.key >> $CONFIG_FILE
  echo "</key>" >> $CONFIG_FILE

  echo "✅ VPN created: $VPN_ENDPOINT_ID"
  echo "Config saved: $CONFIG_FILE"
  echo ""
  echo "Note: Keep client.crt and client.key files - they are needed for authentication"
}

connect_vpn() {
  [ ! -f "$CONFIG_FILE" ] && echo "Error: $CONFIG_FILE not found. Run './vpn.sh create' first" && exit 1
  
  # Try to auto-update profile
  if [ -f ~/.config/AWSVPNClient/OpenVpnConfigs/MMA-VPN ]; then
    cp $CONFIG_FILE ~/.config/AWSVPNClient/OpenVpnConfigs/MMA-VPN
    echo "✅ Profile refreshed"
    killall "AWS VPN Client" 2>/dev/null || true
    sleep 1
    open -a "AWS VPN Client"
  else
    echo "Manual setup required:"
    echo "1. Open AWS VPN Client"
    echo "2. Click 'File' > 'Manage Profiles'"
    echo "3. Click 'Add Profile'"
    echo "4. Display Name: MMA-VPN"
    echo "5. VPN Configuration File: $PWD/$CONFIG_FILE"
    echo "6. Click 'Add Profile' then 'Done'"
    echo "7. Click 'Connect'"
    open -a "AWS VPN Client"
  fi
}

case "$1" in
  create)
    create_vpn
    ;;
  connect)
    connect_vpn
    ;;
  *)
    echo "Usage: $0 {create|connect}"
    echo "  create  - Create AWS Client VPN endpoint"
    echo "  connect - Connect to VPN"
    exit 1
    ;;
esac
