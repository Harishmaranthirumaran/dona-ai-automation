#!/bin/bash
# Backup n8n workflows to S3
# Author: Harishmaran Subbaiah Thirumaran
# Runs daily via cron: 0 2 * * * /home/ec2-user/dona-ai-automation/scripts/backup-workflows.sh

set -euo pipefail

S3_BUCKET=${S3_BUCKET:-"dona-backups"}
BACKUP_DIR="/tmp/dona-backup-$(date +%Y%m%d-%H%M%S)"
N8N_CONTAINER=${N8N_CONTAINER:-"dona-n8n-1"}

mkdir -p "$BACKUP_DIR"

echo "Starting workflow backup..."

# Export workflows from n8n
docker exec "$N8N_CONTAINER" n8n export:workflow --all --output=/tmp/workflows.json
docker cp "$N8N_CONTAINER":/tmp/workflows.json "$BACKUP_DIR/workflows.json"

# Export credentials metadata (no secrets)
docker exec "$N8N_CONTAINER" n8n export:credentials --all --output=/tmp/credentials.json 2>/dev/null || true
docker cp "$N8N_CONTAINER":/tmp/credentials.json "$BACKUP_DIR/credentials.json" 2>/dev/null || true

# Compress
tar -czf "${BACKUP_DIR}.tar.gz" -C "$(dirname $BACKUP_DIR)" "$(basename $BACKUP_DIR)"

# Upload to S3
aws s3 cp "${BACKUP_DIR}.tar.gz" "s3://${S3_BUCKET}/workflows/$(date +%Y/%m)/"

# Cleanup
rm -rf "$BACKUP_DIR" "${BACKUP_DIR}.tar.gz"

echo "✅ Backup complete: s3://${S3_BUCKET}/workflows/$(date +%Y/%m)/"
