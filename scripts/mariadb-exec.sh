#!/usr/bin/env bash
set -euo pipefail

NS="mariadb"
SECRET="mariadb"
POD="mariadb-0"

PASSWORD=$(kubectl get secret "$SECRET" -n "$NS" -o jsonpath='{.data.password}' | base64 -d)

echo "Connecting to MariaDB primary ($POD) as root..."

kubectl exec -it "$POD" -n "$NS" -- mariadb -u root "-p${PASSWORD}"
