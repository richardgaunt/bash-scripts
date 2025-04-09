#!/bin/bash

ANTHROPIC_API_KEY="$1"

curl https://api.anthropic.com/v1/models \
	     --silent \
	     --header "x-api-key: $ANTHROPIC_API_KEY" \
	          --header "anthropic-version: 2023-06-01" \
		  | jq -r '.data[].id'
