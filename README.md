# TTS Server

> Create custom TTS model for XTTS V2 engine

This project is a customized build of [AllTalk V2](https://github.com/erew123/alltalk_tts/tree/alltalkbeta) for personal use on Ubuntu v24.

## Initial Setup

### Install DeepSpeed Dependencies

```bash
sudo apt install libaio-dev espeak-ng gcc g++
```

### Setup AllTalk V2

Setup Python Environment and download core dependencies.

```bash
# Run the Setup Script
./atsetup.sh
```

## Download Custom TTS Assets

Download my custom assets from AWS used by the TTS Server.

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

## Starting TTS Server

Now that everything is setup, we can run the TTS Server.

```bash
# Start TTS Server
./start_server.sh
```

The server should now be running at `http://127.0.0.1:7851`

## Ubuntu TTS Service

During the setup process a new `tts-server.service` was created.

If you wish to use this, you can do the following:

```bash
# Start TTS Server at http://127.0.0.1:7851
systemctl start tts-server

# Stop TTS Server
systemctl stop tts-server

# Restart TTS Server
systemctl restart tts-server
```

You can then manage the TTS Service on boot via:

```bash
# Enable TTS Server on Boot
systemctl enable tts-server

# Disable TTS Server on boot
systemctl disable tts-server
```
