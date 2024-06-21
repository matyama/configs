#!/usr/bin/env bash

# Resources
#  - API reference: https://dev.bitly.com/
#  - Retrieve `BITLY_TOKEN` from https://app.bitly.com/settings/api/

set -eu

__USAGE="Shorten URLs using Bitly.

USAGE:
	$(basename $0) [-h|--help] [-g|--group] URL

Environment:
 - BITLY_TOKEN       Bitly API token (required)
 - BITLY_ORG_NAME    name of the Bitly organization used to select 'group_guid'
	                   (optional, default: any 'free' tier family, '--org' takes
										 precedence)
 - BITLY_GROUP_NAME  name of a group for which to select 'group_guid'
	                   (optional, default: '$USER', '--group' takes precedence)

API access:
 - organization guid is one for given 'BITLY_ORG_NAME' (defaults to any org in
   the 'free' tier family)
 - group guid is one for given 'BITLY_GROUP_NAME' (defualts to current user)

Dependencies:
 - curl
 - jq
"

usage() {
	echo "$__USAGE"
}

[ -v BITLY_TOKEN ] || ("'BITLY_TOKEN' not found in env" && exit 1)

POSITIONAL_ARGS=()

ORG_NAME="${BITLY_ORG_NAME:-free}"
GROUP_NAME="${BITLY_GROUP_NAME:-$USER}"

while [[ $# -gt 0 ]]; do
  case "${1}" in
		-h|--help)
			usage
			exit 0
			;;
		-o|--org)
			ORG_NAME="${2}"
			shift
			shift
			;;
		-g|--group)
			GROUP_NAME="${2}"
			shift
			shift
			;;
		*)
			POSITIONAL_ARGS+=("$1")
			shift
			;;
	esac
done

# restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

[[ $# -gt 0 ]] || (usage && exit 1)

# TODO: accept multiple URLs at once (output one per line) and from stdin
LONG_URL="$1"

ORGANIZATION_GUID=$(
	curl \
		--connect-timeout 10 \
		--max-time 30 \
		-sS \
		-H "Authorization: Bearer ${BITLY_TOKEN}" \
		-X GET \
		https://api-ssl.bitly.com/v4/organizations \
		| jq \
			-re \
			--arg n "${ORG_NAME}" \
			'.organizations[] | select(.name == $n or .tier_family == $n) | .guid'
)

GROUP_GUID=$(
	curl \
		--connect-timeout 10 \
		--max-time 30 \
		-sS \
		-H "Authorization: Bearer ${BITLY_TOKEN}" \
		-X GET \
		-G \
		-d organization_guid="${ORGANIZATION_GUID}" \
		"https://api-ssl.bitly.com/v4/groups" \
		| jq \
				-re \
				--arg group_name "${GROUP_NAME}" \
				'.groups[] | select(.name == $group_name) | .guid'
)

jq \
	-ne \
	--arg long_url "${LONG_URL}" \
	--arg group_guid "${GROUP_GUID}" \
	'{
		"long_url": $long_url,
		"domain": "bit.ly",
		"group_guid": $group_guid
	}' \
	| curl \
			--connect-timeout 10 \
			--max-time 30 \
			-sS \
			-H "Authorization: Bearer ${BITLY_TOKEN}" \
			-H "Content-Type: application/json" \
			-X POST \
			-d @- \
			https://api-ssl.bitly.com/v4/shorten \
	| jq -re '.link // empty'
