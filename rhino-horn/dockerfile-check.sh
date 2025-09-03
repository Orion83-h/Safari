#!/bin/bash

# This script checks if the Dockerfile defines a non-root USER.
# It exits with an error if the USER is not set or is root.

set -euo pipefail

if ! grep -q '^USER ' rhino-horn/Dockerfile; then
  echo "Error: Dockerfile missing non-root USER directive."
  exit 1
fi

user=$(grep '^USER ' rhino-horn/Dockerfile | tail -1 | awk '{print $2}')

if [[ "$user" == "root" || "$user" == "0" ]]; then
  echo "Error: Dockerfile uses root user ($user)."
  exit 1
fi

echo "Dockerfile defines secure non-root USER: $user"