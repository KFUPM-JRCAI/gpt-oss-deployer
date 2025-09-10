# GPT-OSS Deployment

This repository provides scripts for serving and interacting with GPT-OSS models.

- **`serve_using_docker.sh`** - A script that uses a pre-built Docker image to serve the model.
- **`serve.sh`** - A script that sets up the environment and serves the model.
- **`interactive_chat.py`** - A Python script that shows how to connect to the API and chat with the model.

## Serving the Model (3 Steps)

### Step 1: Check System Compatibility
Ensure your system has:
- **Git** and **Git LFS**: You need these to download the model files.
- **CUDA Toolkit 12.8**: Only required if you're using the serve.sh script.
- **Docker**: Only required if you're using the Docker deployment.

### Step 2: Download the Model
First, you'll need to install Git LFS, then use Git to clone the model from Hugging Face.
```bash
git lfs install
git clone https://huggingface.co/openai/gpt-oss-120b
```

### Step 3: Run the Serve Script

The model can be loaded on a single GPU with 80 GB of memory. For workloads requiring a higher volume of simultaneous requests, you can load it to 2 GPUs.  

You can serve the model using one of the following two methods, the model API will be available at http://[SERVER_IP]:8010/v1:

#### Option A: Docker 🐳 Deployment 
This option uses a pre-built Docker container, so we don't have to worry about dependencies:
```bash
./serve_using_docker.sh ./gpt-oss-120b --gpus "0,1" --port 8010
```

#### Option B: Native Deployment
This option sets up the environment and serves the API:
```bash
./serve.sh ./gpt-oss-120b --gpus "0,1" --port 8010
```

#### Script Arguments
- **`/path/to/model`** (required) - Local path to model directory
- **`--gpus`** (optional, default: `"0"`) - Comma-separated GPU IDs
- **`--port`** (optional, default: `8020`) - HTTP server port

## Using the Model

### Python API Usage
To use the model in your own applications, you can use the OpenAI Python client. The served model provides an OpenAI-compatible HTTP API:  

First, install the library:
```bash
uv pip install openai
```

Then, use the following code in your Python app to connect to the model:
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

### Interactive Chat Client
You can run the following script to to start an interactive conversation:
```bash
python interactive_chat.py --api-url http://localhost:8010/v1 --model-name gpt-oss-120b --api-token "any string"
```

#### Interactive Chat Arguments
- **`--api-url`** (required) - API base URL (e.g., http://localhost:8010/v1)
- **`--model-name`** (required) - The model name to use
- **`--api-token`** (required) - API authentication token, in our case any string will work.

