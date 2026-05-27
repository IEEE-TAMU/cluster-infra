#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="portal"
APP="portal"
CONTAINER="portal"

# Get the portal pod name dynamically
POD=$(kubectl get pods -n "$NAMESPACE" -l app="$APP" -o jsonpath='{.items[0].metadata.name}')

if [[ -z "$POD" ]]; then
  echo "Error: No portal pod found" >&2
  exit 1
fi

echo "Connecting to $POD..."
kubectl exec -it "$POD" -n "$NAMESPACE" -c "$CONTAINER" -- /app/bin/ieee_tamu_portal remote
