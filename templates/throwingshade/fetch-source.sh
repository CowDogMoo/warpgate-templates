#!/usr/bin/env bash
# Download the throwingshade source archive for one commit into this template's
# build context, then print the version string to embed in the binary.
#
# Usage: ./fetch-source.sh <full-commit-sha>
#
# The repository is private. The download uses the GitHub CLI's existing login
# (or GH_TOKEN), so the credential stays on this host and never enters the
# image build.
set -euo pipefail

repo="${THROWINGSHADE_REPO:-CowDogMoo/throwingshade}"
ref="${1:-}"

if [[ ! "${ref}" =~ ^[0-9a-f]{40}$ ]]; then
	echo "usage: $0 <full 40-character commit SHA>" >&2
	exit 1
fi

template_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
archive="${template_dir}/throwingshade-src.tar.gz"
tmp="$(mktemp "${archive}.XXXXXX")"
trap 'rm -f "${tmp}"' EXIT

echo "Fetching ${repo}@${ref}" >&2
gh api "repos/${repo}/tarball/${ref}" >"${tmp}"

# get-tar-commit-id stops after the header, so gzip may die of SIGPIPE.
archived="$( (gzip -dc "${tmp}" || true) | git get-tar-commit-id)"
if [[ "${archived}" != "${ref}" ]]; then
	echo "archive is commit '${archived}', expected ${ref}" >&2
	exit 1
fi

mv "${tmp}" "${archive}"
trap - EXIT
echo "Wrote ${archive}" >&2

# Mirror `git describe --tags --always`, which throwingshade's own build uses:
# the newest tag the commit descends from, plus the distance and short SHA.
short="${ref:0:7}"
version="${short}"
while IFS= read -r tag; do
	[[ -n "${tag}" ]] || continue
	read -r status ahead < <(gh api "repos/${repo}/compare/${tag}...${ref}" \
		--jq '"\(.status) \(.ahead_by)"' 2>/dev/null || echo "error 0")
	case "${status}" in
	identical)
		version="${tag}"
		break
		;;
	ahead)
		version="${tag}-${ahead}-g${short}"
		break
		;;
	esac
done < <(gh api "repos/${repo}/tags" --paginate --jq '.[].name' 2>/dev/null | sort -rV | head -n 5)

echo "${version}"
