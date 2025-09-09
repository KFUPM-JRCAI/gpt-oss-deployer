#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 /path/to/model [--gpus \"0,1,2\"] [--port 8020]"
  exit 1
fi

MODEL_PATH="$1"
shift
GPUS="0"
PORT="8020"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --gpus) GPUS="$2"; shift 2 ;;
    --port) PORT="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

IFS=',' read -r -a GPU_ARRAY <<< "${GPUS}"
TP_SIZE="${#GPU_ARRAY[@]}"

IS_A100=false
for gpu_id in "${GPU_ARRAY[@]}"; do
  gpu_name=$(nvidia-smi --query-gpu=name --format=csv,noheader -i "$gpu_id")
  if [[ "$gpu_name" == *"A100"* ]]; then
    IS_A100=true
  fi
done

MODEL_PATH="$(realpath "$MODEL_PATH")"
MODEL_NAME="$(basename "$MODEL_PATH")"

ENV_ARGS=""
if [[ "$IS_A100" == true ]]; then
  ENV_ARGS="-e VLLM_ATTENTION_BACKEND=TRITON_ATTN_VLLM_V1"
fi

echo $MODEL_PATH

docker run --security-opt apparmor=unconfined \
  --gpus "\"device=${GPUS}\"" \
  --runtime=nvidia \
  $ENV_ARGS \
  -p "${PORT}:${PORT}" \
  --ipc=host \
  -v "${MODEL_PATH}:/model" \
  vllm/vllm-openai:gptoss \
  --model /model \
  --tensor_parallel_size "${TP_SIZE}" \
  --host 0.0.0.0 \
  --port "${PORT}" \
  --served-model-name "${MODEL_NAME}"