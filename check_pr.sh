#!/bin/sh

#GITHUB_REPO_GIT_URL=git://github.com/mgm-sandbox/magma.git
#GITHUB_PR_SOURCE_REPO_OWNER=mgm-sandbox
REPO=`echo $GITHUB_REPO_GIT_URL | awk -F/ '{print gensub("\\\.git$", "", "g", $NF)}'`
#GITHUB_PR_NUMBER=4

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

generate_pr_status_gql | gh api graphql -f query="`cat`" 2>&1 | tee /tmp/pr_state
gh pr checks $GITHUB_PR_NUMBER -R $GITHUB_PR_SOURCE_REPO_OWNER/$REPO 2>&1 | tee /tmp/check_state


REVIEW_DECISION=`cat /tmp/pr_state | jq -r '.data.repository.pullRequest.reviewDecision'`
HAVE_READY_LABEL=`cat /tmp/pr_state | jq -r '.data.repository.pullRequest.labels.nodes[] | select(.name == "ready-for-merge").name'`

if [ "x$REVIEW_DECISION" != "xAPPROVED" ]; then 
  echo "Review decision($REVIEW_DECISION) != APPROVED"
  exit 0
fi

if [ "x$HAVE_READY_LABEL" != "xready-for-merge" ]; then
  echo "No ready-for-merge label"
  exit 0
fi

echo "Okay, looks good, let's merge"

gh pr merge $GITHUB_PR_NUMBER -m -R $GITHUB_PR_SOURCE_REPO_OWNER/$REPO 


exit 0
