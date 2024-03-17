#!/bin/bash
apk --no-cache add postgresql-client
# Function to wait for a service to become available
wait_for_service() {
  local service="$1"
  local port="$2"
  local max_attempts=30
  local attempt=0

  echo "Waiting for $service to become available..."
  while ! nc -z "$service" "$port" >/dev/null 2>&1; do
    if [ $attempt -eq $max_attempts ]; then
      echo "Failed to connect to $service:$port after $max_attempts attempts."
      exit 1
    fi
    attempt=$((attempt + 1))
    sleep 1
  done
}

# Wait for PostgreSQL services to become available
wait_for_service "check-update-platform" 8080
wait_for_service "stackoverflow-plugin" 8081

# Execute SQL scripts
echo "Executing SQL scripts..."
PGPASSWORD=pass psql -h postgresql-platform -d platform -U user -f ./init/platform-init.sql

echo "Initialization complete."