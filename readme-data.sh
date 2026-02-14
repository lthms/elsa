#!/usr/bin/env bash
set -euo pipefail

tools=$(yq -p=toml -o=json '.tools | to_entries | map({
  "name": (.key | sub("github:.*/", "")),
  "version": .value
})' mise.toml)

targets=$(grep -E '^[a-z][a-z_-]*: ##' makefile \
  | sed 's/: ## /\t/' \
  | jq -Rn '[inputs | split("\t") | {"name": .[0], "description": .[1]}]')

variables=$(yq -p=hcl -o=json '.variable | to_entries' variables.tf)

required=$(echo "$variables" | jq '[.[] | select(.value.default == null) | {
  "name": .key,
  "description": .value.description
}]')

optional=$(echo "$variables" | jq '[.[] | select(.value.default != null) | {
  "name": .key,
  "description": .value.description,
  "default": (.value.default | tostring)
}]')

jq -n \
  --argjson tools "$tools" \
  --argjson targets "$targets" \
  --argjson required "$required" \
  --argjson optional "$optional" \
  '{
    "tools": $tools,
    "targets": $targets,
    "required_variables": $required,
    "optional_variables": $optional
  }'
