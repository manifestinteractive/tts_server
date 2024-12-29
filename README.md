# TTS Server

Create custom TTS model for XTTS V2 engine

This project is based on [AllTalk V2](https://github.com/erew123/alltalk_tts/tree/alltalkbeta)

## Developer Setup

```bash
# Run the Setup Script
./atsetup.sh
```

## Downloading Assets

```bash
# Download AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "aws-cli.zip"
unzip aws-cli.zip
sudo ./aws/install

# Remove temp files
rm -fr aws
rm -fr aws-cli.zip

# Set Env Variables in ~/.bashrc or ~/.profile
export AWS_ACCESS_KEY_ID="CHANGE_ME"
export AWS_SECRET_ACCESS_KEY="CHANGE_ME"
export AWS_DEFAULT_REGION="CHANGE_ME"

# Download TTS Assets from AWS
./download_assets.sh
```
