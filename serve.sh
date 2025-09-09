#!/usr/bin/env bash
set -euo pipefail

# -----------------------------
# Usage and argument validation
# -----------------------------
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/model [--gpus \"0,1,2\"] [--port 8020]"
  exit 1
fi

MODEL_PATH="$1"
shift

GPUS="0"       # default to GPU 0 if not given
PORT="8020"    # default port

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gpus) GPUS="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# -----------------------------
# Compute tensor parallel size
# -----------------------------
IFS=',' read -r -a GPU_ARRAY <<< "${GPUS}"
TP_SIZE="${#GPU_ARRAY[@]}"

# -----------------------------
# Detect GPU type(s)
# -----------------------------
IS_A100=false
for gpu_id in "${GPU_ARRAY[@]}"; do
  gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader -i "$gpu_id")
  echo "GPU $gpu_id: $gpu_name"
  if [[ "$gpu_name" == *"A100"* ]]; then
    IS_A100=true
  fi
done

# -----------------------------
# Install uv if missing
# -----------------------------
if ! command -v uv &> /dev/null; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# -----------------------------
# Create virtual environment
# -----------------------------
if [[ ! -d ".venv" ]]; then
  uv venv --python 3.12 --seed
fi
source .venv/bin/activate

# -----------------------------
# Install vLLM
# -----------------------------
export CUDA_VISIBLE_DEVICES="${GPUS}"
if [[ "$IS_A100" == true ]]; then
  export VLLM_ATTENTION_BACKEND="TRITON_ATTN_VLLM_V1"
  echo "A100 detected → using VLLM_ATTENTION_BACKEND=TRITON_ATTN_VLLM_V1"
fi

uv pip install --pre vllm==0.10.1+gptoss \
  --extra-index-url https://wheels.vllm.ai/gpt-oss/ \
  --extra-index-url https://download.pytorch.org/whl/nightly/cu128 \
  --index-strategy unsafe-best-match

# -----------------------------
# Serve model
# -----------------------------
echo "Starting vLLM server on port ${PORT} with GPUs ${GPUS}..."
vllm serve "${MODEL_PATH}" \
  --tensor_parallel_size "${TP_SIZE}" \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --served-model-name "$(basename "${MODEL_PATH}")"
