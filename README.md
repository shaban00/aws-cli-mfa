# AWS CLI MFA

A simple Bash script to generate temporary AWS CLI credentials using MFA (Multi-Factor Authentication), and store them under a separate AWS CLI profile.

## 📦 Features

- Prompts for MFA token
- Generates temporary session credentials using AWS STS
- Stores credentials in a new profile (e.g., `<profile>-mfa`)
- Supports custom AWS region

---

## 📋 Requirements

- AWS CLI installed and configured
- jq installed (for parsing JSON)

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

### 🚀 Usage

#### Configure AWS CLI

```bash
aws configure --profile <profile-name>
```

### Required Arguments

- `--profile`: Name of the AWS CLI profile to use (must already be configured in your system).
- `--arn`: The MFA device ARN for the IAM user (can be found in AWS IAM Console).

### Optional Argument

- `--region`: AWS region (default is us-east-1).

#### Configure AWS CLI MFA

```bash
./aws-cli-mfa.sh --profile <profile-name> --arn <mfa-arn> [--region <aws-region>]
```

**NOTE:** The session token duration is **24 hours**

#### 🔐 Example 1

```bash
./aws-cli-mfa.sh --profile myprofile --arn arn:aws:iam::123456789012:mfa/testuser --region us-west-2
```

#### Configure your bash or zsh shell with AWS CLI MFA script

Use the text editor or your choice

For **bash**

```bash
nano ~/.bashrc
```

For **zsh**

```zsh
nano ~/.zshrc
```

Copy and paste this code at the bottom of the file. Update the **arn** with your **mfa-arn** from the AWS console.

```bash
aws-cli-mfa() {
  # Define profiles and ARNs here. Format: "profile_name|arn"
  local profile_data=(
    "profile_name_1|mfa_arn_1" # Format: arn:aws:iam::123456789012:mfa/testuser
    "profile_name_2|mfa_arn_2"
    "profile_name_3|mfa_arn_1"
  )

  # Function to get ARN for a given profile
  get_arn_for_profile() {
    local search_profile="$1"
    for item in "${profile_data[@]}"; do
      local profile="${item%%|*}"
      local arn="${item##*|}"
      if [ "$profile" = "$search_profile" ]; then
        echo "$arn"
        return 0
      fi
    done
    echo ""
  }

  # Function to list all available profiles
  list_profiles() {
    for item in "${profile_data[@]}"; do
      local profile="${item%%|*}"
      echo "  - $profile"
    done
  }

  local input_profile="$1"

  if [ -n "$input_profile" ]; then
    local arn=$(get_arn_for_profile "$input_profile")

    if [ -n "$arn" ]; then
      ~/aws-cli-mfa.sh --profile "$input_profile" --arn "$arn" && export AWS_PROFILE="${input_profile}-mfa"
    else
      echo "Error: Profile '$input_profile' not found."
      echo "Available profiles:"
      list_profiles
    fi
  else
    echo "Usage: aws-cli-mfa <profile-name>"
  fi
}
```

For **bash**

```bash
source ~/.bashrc
```

For **zsh**

```zsh
source ~/.zshrc
```

#### 🔐 Example 2

```bash
aws-cli-mfa <profile-name>
```

#### Activate MFA profile in a new shell

```bash
export AWS_PROFILE="<profile-name>-mfa"
```

#### Verify Profile

```bash
echo $AWS_PROFILE
```
