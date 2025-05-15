# AWS CLI MFA

A simple Bash script to generate temporary AWS CLI credentials using MFA (Multi-Factor Authentication), and store them under a separate AWS CLI profile.

## 📦 Features

- Prompts for MFA token
- Generates temporary session credentials using AWS STS
- Stores credentials in a new profile (e.g., `<profile>-mfa`)
- Supports custom AWS region

---

## 📥 Download

You can download the script using `curl` or `wget`:

### Using curl

```bash
curl -O https://raw.githubusercontent.com/shaban00/aws-cli-mfa/main/aws-cli-mfa.sh
chmod +x aws-cli-mfa.sh
```

### Or using wget

```bash
wget https://raw.githubusercontent.com/shaban00/aws-cli-mfa/main/aws-cli-mfa.sh
chmod +x aws-cli-mfa.sh
```

## 🚀 Usage

```bash
./aws-cli-mfa.sh --profile <profile-name> --arn <mfa-arn> [--region <aws-region>]
```

### Required Arguments

- `--profile`: Name of the AWS CLI profile to use (must already be configured in your system).
- `--arn`: The MFA device ARN for the IAM user (can be found in AWS IAM Console).

### Optional Argument

- `--region`: AWS region (default is us-east-1).

## 🔐 Example

```bash
./aws-cli-mfa.sh --profile myuser --arn arn:aws:iam::123456789012:mfa/myuser --region us-west-2
```

## 📋 Requirements

- AWS CLI installed and configured
- jq installed (for parsing JSON)
