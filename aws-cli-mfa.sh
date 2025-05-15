#!/bin/bash

# === Default values ===
REGION="us-east-1"
MFA_PROFILE_NAME=""  # Will be set based on profile argument

# === Parse command-line arguments ===
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --profile)
      PROFILE_NAME="$2"
      MFA_PROFILE_NAME="${2}-mfa"
      shift
      ;;
    --arn)
      MFA_ARN="$2"
      shift
      ;;
    --region)
      REGION="$2"
      shift
      ;;
    *)
      echo "❌ Unknown parameter passed: $1"
      echo "Usage: $0 --profile <profile-name> --arn <mfa-arn> [--region <aws-region>]"
      exit 1
      ;;
  esac
  shift
done

# === Validate required parameters ===
if [[ -z "$PROFILE_NAME" || -z "$MFA_ARN" ]]; then
  echo "❌ Missing required parameters."
  echo "Usage: $0 --profile <profile-name> --arn <mfa-arn> [--region <aws-region>]"
  exit 1
fi

# === Check if profile exists ===
if ! aws configure list-profiles 2>/dev/null | grep -Fxq "$PROFILE_NAME"; then
  echo "❌ AWS profile '$PROFILE_NAME' does not exist."
  exit 1
fi


# === Prompt for MFA code ===
read -p "Enter MFA code for $PROFILE_NAME: " TOKEN_CODE


# === Get session token ===
CREDENTIALS=$(aws sts get-session-token \
  --serial-number "$MFA_ARN" \
  --token-code "$TOKEN_CODE" \
  --profile "$PROFILE_NAME" \
  --region "$REGION" \
  --output json)

# === Check if the command was successful ===
if [ $? -ne 0 ]; then
  echo "❌ Failed to retrieve session token."
  exit 1
fi

# === Parse credentials ===
AWS_ACCESS_KEY_ID=$(echo "$CREDENTIALS" | jq -r '.Credentials.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo "$CREDENTIALS" | jq -r '.Credentials.SecretAccessKey')
AWS_SESSION_TOKEN=$(echo "$CREDENTIALS" | jq -r '.Credentials.SessionToken')

# === Configure temporary profile ===
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile "$MFA_PROFILE_NAME"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile "$MFA_PROFILE_NAME"
aws configure set aws_session_token "$AWS_SESSION_TOKEN" --profile "$MFA_PROFILE_NAME"
aws configure set region "$REGION" --profile "$MFA_PROFILE_NAME"
aws configure set output json --profile "$MFA_PROFILE_NAME"

echo "✅ MFA temporary credentials configured under profile: $MFA_PROFILE_NAME"
