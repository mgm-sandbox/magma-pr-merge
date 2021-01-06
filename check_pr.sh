#!/bin/sh

GITHUB_REPO_GIT_URL=git://github.com/mgm-sandbox/magma.git
GITHUB_PR_SOURCE_REPO_OWNER=mgm-sandbox
REPO=`echo $GITHUB_REPO_GIT_URL | awk -F/ '{print gensub("\\\.git$", "", "g", $NF)}'`
GITHUB_PR_NUMBER=4

generate_pr_status_gql() {
cat<<EOF
{
  repository(owner: "$GITHUB_PR_SOURCE_REPO_OWNER", name: "$REPO") {
    pullRequest(number: $GITHUB_PR_NUMBER) {
      url
      labels(last: 100) {
        nodes {
          name
        }
      }

      reviews(last: 1) {
        totalCount
        nodes {
          state
        }
      }
      reviewDecision
    }
  }
}
EOF
} 

generate_pr_status_gql | gh api graphql -f query="`cat`" 
gh pr checks $GITHUB_PR_NUMBER -R $GITHUB_PR_SOURCE_REPO_OWNER/$REPO
