#!/bin/bash

azd env get-values > .env
source .env

cat <<EOF > .vscode/mcp.json
{
	"servers": {
		"setlistfm": {
			"url": "${FABRIC_MCP_ENDPOINT}",
			"type": "http",
			"headers": {
				"Ocp-Apim-Subscription-Key":"${FABRIC_REST_APIM_SUBSCRIPTION_KEY}"
			}
		}
	},
	"inputs": []
}
EOF