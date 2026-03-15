#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KUBECONFIG="$SCRIPT_DIR/../k3s.yaml"
export KUBECONFIG

HOSTS=(
    "ieee-tamu-5B"
    "ieee-tamu-7P"
    "ieee-tamu-8J"
    "ieee-tamu-6Q"
)

JUMP_HOST="root@ieee-tamu.engr.tamu.edu"

# Parse command line arguments
NO_DRAIN=false
NO_REBOOT=false
for arg in "$@"; do
    if [ "$arg" = "--no-drain" ]; then
        NO_DRAIN=true
    elif [ "$arg" = "--no-reboot" ]; then
        NO_REBOOT=true
    fi
done

for host in "${HOSTS[@]}"; do
    echo "========================================"
    echo "Updating $host..."
    echo "========================================"

    NODE_NAME="${host,,}"

    # Handle draining based on NO_DRAIN flag
    if [ "$NO_DRAIN" = false ]; then
        CORDONED=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.unschedulable}' 2>/dev/null || echo "unknown")

        if [ "$CORDONED" != "true" ]; then
            echo "Node $NODE_NAME is not cordoned. Draining..."
            WAS_CORDONED=false
            kubectl drain "$NODE_NAME" --ignore-daemonsets --delete-emptydir-data --force
        else
            echo "Node $NODE_NAME is already cordoned. Skipping drain."
            WAS_CORDONED=true
        fi
    else
        echo "Skipping drain due to --no-drain flag"
        WAS_CORDONED=$(kubectl get node "$NODE_NAME" -o jsonpath='{.spec.unschedulable}' 2>/dev/null || echo "unknown")
        if [ "$WAS_CORDONED" = "true" ]; then
            WAS_CORDONED=true
        else
            WAS_CORDONED=false
        fi
    fi

    # nixos-rebuild with or without reboot
    echo "Running nixos-rebuild on $host..."
    ssh -J "$JUMP_HOST" "root@$host" "nixos-rebuild switch --flake github:ieee-tamu/nix-cluster --refresh"

    # Skip waiting for reboot if NO_REBOOT is true
    if [ "$NO_REBOOT" = false ]; then
        ssh -J "$JUMP_HOST" "root@$host" "reboot"
        echo "Waiting for $NODE_NAME to go down for reboot..."
        TIMEOUT=60
        ELAPSED=0
        while [ $ELAPSED -lt $TIMEOUT ]; do
            STATUS=$(kubectl get node "$NODE_NAME" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "")
            if [ "$STATUS" != "True" ]; then
                echo "Node $NODE_NAME is now NotReady."
                break
            fi
            sleep 2
            ELAPSED=$((ELAPSED + 2))
        done

        if [ $ELAPSED -ge $TIMEOUT ]; then
            echo "Warning: $NODE_NAME did not go NotReady within ${TIMEOUT}s, proceeding anyway..."
        fi

        echo "Waiting for $NODE_NAME to become Ready..."
        until kubectl get node "$NODE_NAME" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null | grep -q "True"; do
            echo "Waiting for $NODE_NAME to be ready..."
            sleep 5
        done
        echo "Node $NODE_NAME is Ready."
    fi

    # Handle uncordoning based on NO_DRAIN flag
    if [ "$NO_DRAIN" = false ]; then
        if [ "$WAS_CORDONED" = false ]; then
            echo "Uncordoning $NODE_NAME..."
            kubectl uncordon "$NODE_NAME"
        else
            echo "Node $NODE_NAME was already cordoned, leaving as-is."
        fi
    fi

    echo "Done with $host."
done

echo "All hosts updated."
