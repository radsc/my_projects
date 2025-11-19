#!/bin/sh
set -e

echo "Starting Ollama..."
ollama serve &

# Wait for Ollama to start
sleep 3

echo "Pulling model: llama3.1"
ollama pull llama3.1

# Keep container alive
wait

chmod +x pull-model.sh