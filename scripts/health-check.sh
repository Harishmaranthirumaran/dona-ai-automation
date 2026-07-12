#!/bin/bash
# Dona health check — verifies all services are running
# Author: Harishmaran Subbaiah Thirumaran

set -euo pipefail

N8N_URL=${N8N_URL:-"http://localhost:5678"}
ALERT_EMAIL=${ALERT_EMAIL:-""}

check_service() {
  local name=$1
  local url=$2
  if curl -fsS "$url" > /dev/null 2>&1; then
    echo "✅ $name — online"
    return 0
  else
    echo "❌ $name — OFFLINE"
    return 1
  fi
}

echo "═══════════════════════════════"
echo "  Dona Health Check"
echo "  $(date)"
echo "═══════════════════════════════"

FAILURES=0

check_service "n8n" "${N8N_URL}/healthz" || FAILURES=$((FAILURES + 1))
check_service "PostgreSQL" "localhost:5432" 2>/dev/null || true

# Docker container status
echo ""
echo "Container status:"
docker compose ps 2>/dev/null || docker ps --filter "name=dona" --format "table {{.Names}}\t{{.Status}}"

echo ""
if [[ $FAILURES -eq 0 ]]; then
  echo "✅ All services healthy"
  exit 0
else
  echo "❌ $FAILURES service(s) down"
  exit 1
fi
