# GPT-OSS-120B Deployment

## Overview
This repository provides scripts for serving and interacting with **GPT-OSS** models:
- **`serve_using_docker.sh`** - A Docker-based deployment script for containerized model serving.
- **`serve.sh`** - A bash script that sets up the environment and serves the model.
- **`interactive_chat.py`** - A Python script that shows an example of how to connect to the API and chat with the model.

## Serving the Model (3 Steps)

### Step 1: Check System Compatibility
Ensure your system has:
- **Git** and **Git LFS**
- **Docker** (if using Docker deployment)
- **CUDA 12.8** (if using **`serve.sh`** script)

### Step 2: Install Git LFS and Clone Model
```bash
git lfs install
git clone https://huggingface.co/openai/gpt-oss-120b
```

### Step 3: Run the Deployment Script

You can deploy the model using either method:

#### Option A: Docker Deployment - Preferred
Alternatively, use Docker for containerized deployment:
```bash
./serve_using_docker.sh ./gpt-oss-120b --gpus "0,1" --port 8010
```

#### Option B: Native Deployment
The following command loads the model on the first 2 GPUs and serves the API via http://[SERVER_IP]:8010/v1
```bash
./serve.sh ./gpt-oss-120b --gpus "0,1" --port 8010
```

#### Script Arguments
- **`/path/to/model`** (required) - Local path to model directory
- **`--gpus`** (optional, default: `"0"`) - Comma-separated GPU IDs
- **`--port`** (optional, default: `8020`) - HTTP server port

## Using the Model

### Interactive Chat Client
Use the included chat client with your server details:
```bash
python interactive_chat.py --api-url http://localhost:8010/v1 --model-name gpt-oss-120b --api-token your_api_token
```

#### Interactive Chat Arguments
- **`--api-url`** (required) - API base URL (e.g., http://localhost:8010/v1)
- **`--model-name`** (required) - The model name to use for chat completions
- **`--api-token`** (required) - API authentication token

This provides an interactive chat session with conversation history. Type 'quit' to exit.

### Python API Usage
For custom applications, you can integrate the model directly into your Python code using the OpenAI client library. The deployed model exposes an OpenAI-compatible HTTP API, allowing you to use familiar OpenAI SDK patterns.

First, install the OpenAI Python library:
```bash
uv pip install openai
```

Then use the API in your Python application:
```python
import openai

client = openai.OpenAI(
    api_key="your_api_token",
    base_url="http://localhost:8010/v1"
)

response = client.chat.completions.create(
    model="gpt-oss-120b",
    messages=[{"role": "user", "content": "What is the color of the sky?"}],
)

print(response.choices[0].message.content)
```