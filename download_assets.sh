#!/bin/bash

# Remove old ./finetune/put-voice-samples-in-here
if [ -d ./finetune/put-voice-samples-in-here ]; then
  rm -fr ./finetune/put-voice-samples-in-here
fi

# Remove old ./models/rvc_voices
if [ -d ./models/rvc_voices ]; then
  rm -fr ./models/rvc_voices
fi

# Remove old ./models/xtts
if [ -d ./models/xtts ]; then
  rm -fr ./models/xtts
fi

# Remove old ./voices
if [ -d ./voices ]; then
  rm -fr ./voices
fi

# Download Training Data
echo -e '\n› Downloading Training Data ...\n\n'
aws s3 cp --recursive s3://ps-tts-training/ ./finetune/put-voice-samples-in-here

# Download RVC Voice Model
echo -e '\n› Downloading RVC Voice Model ...\n\n'
aws s3 cp --recursive s3://ps-tts-model-rvc/ ./models/rvc_voices

# Download XTTS Model
echo -e '\n› Downloading XTTS Model ...\n\n'
aws s3 cp --recursive s3://ps-tts-model-xtts/ ./models/xtts

# Download Voices
echo -e '\n› Downloading Voices ...\n\n'
aws s3 cp --recursive s3://ps-tts-voices/ ./voices