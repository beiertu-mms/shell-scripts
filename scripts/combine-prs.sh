#!/usr/bin/env bash
#===============================================================================
# Combine multiple braches, which match the search criteria into one new brach.
#
# Requirements: gh (github-cli), git
#===============================================================================

set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

function print_usage() {
	cat <<EOF
usage: ./combine-prs.sh [OPTIONS]

Options:
-b  default head branch to be checkout from. Default: master
-c  feature branch name to be used. Default: build/deps/bump-versions
-s  earch criteria for branches to be considered in the combination. Default: dependabot/
*   show this usage.
EOF
	exit 1
}

function run() {
	local RED='\033[0;31m'
	local GREEN='\033[0;32m'
	local YELLOW='\033[0;33m'
	local NC='\033[0m' # No Color

	# Parse arguments
	local base_branch="master"
	local combine_branch_name="build/deps/bump-versions"
	local search_branch_name="dependabot/"

	while getopts ":b:c:s:" option; do
		case "${option}" in
		b) base_branch=${OPTARG} ;;
		c) combine_branch_name=${OPTARG} ;;
		s) search_branch_name=${OPTARG} ;;
		*) print_usage ;;
		esac
	done
	shift $((OPTIND - 1))

	# Update and checkout to new branch
	local current_branch

	current_branch=$(git branch | grep -F '*' | cut -d' ' -f2)
	if [[ "$current_branch" != "$combine_branch_name" ]]; then
		git stash
		git checkout "$base_branch"
		git pull --ff-only
		git branch -D "$combine_branch_name"
		git checkout -b "$combine_branch_name"
		echo ""
	fi

	# Search and apply patches
	local pr_count
	local id
	local msg

	pr_count=$(gh pr list | grep -c "$search_branch_name")
	echo -e "${GREEN}about to apply ${pr_count} PRs${NC}"

	gh pr list | grep "$search_branch_name" | while read -r pr; do
		id=$(echo "$pr" | cut -f1 | xargs)
		msg=$(echo "$pr" | cut -f2 | xargs)

		echo -e "${GREEN}try to apply pr #${id}...${NC}"
		if gh pr diff "$id" | git apply; then
			git commit --all --no-verify --message "$msg"
			echo -e "${GREEN}pr #${id}: '${msg}' apply successfully${NC}\n"
		else
			echo -e "${RED}failed to apply pull request, try with merge with 'theirs' strategy${NC}"
			git merge "origin/$(echo "$pr" | cut -f3 | xargs)" \
				--message "$msg" \
				--strategy-option theirs \
				--verbose
			echo -e "${YELLOW}merge pr #${id}: '${msg}'${NC}"
		fi
		echo ""
	done

	git rebase --interactive "HEAD~${pr_count}"
}

##############
# RUN SCRIPT #
##############
run "$@"
