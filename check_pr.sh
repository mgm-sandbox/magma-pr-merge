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
      state
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

# gathering data about PR 
generate_pr_status_gql | gh api graphql -f query="`cat`" 2>&1 | tee /tmp/pr_state
gh pr checks $GITHUB_PR_NUMBER -R $GITHUB_PR_SOURCE_REPO_OWNER/$REPO 2>&1 | tee /tmp/check_state

PR_STATE=`cat /tmp/pr_state | jq -r '.data.repository.pullRequest.state'`

REVIEW_DECISION=`cat /tmp/pr_state | jq -r '.data.repository.pullRequest.reviewDecision'`
HAVE_READY_LABEL=`cat /tmp/pr_state | jq -r '.data.repository.pullRequest.labels.nodes[] | select(.name == "ready-for-merge").name'`

# check only OPEN PR's
if [ "x$PR_STATE" != "xOPEN" ]; then
  echo "PR state $PR_STATE is not OPEN, skip" 
  exit 0
fi

# is approved? 
if [ "x$REVIEW_DECISION" != "xAPPROVED" ]; then 
  echo "Review decision($REVIEW_DECISION) != APPROVED"
  exit 0
fi

# have ready-for-merge label?
if [ "x$HAVE_READY_LABEL" != "xready-for-merge" ]; then
  echo "No ready-for-merge label"
  exit 0
fi

! grep -r '^continuous-integration/circle.*pass.*' /tmp/check_state
CIRCLE_CI_PASS=$?

! grep -r '^continuous-integration/jenkins.*pass.*' /tmp/check_state
JENKINS_CI_PASS=$?

! grep -r '^continuous-integration/integration-test.*pass.*' /tmp/check_state
INTEGRATION_TEST_PASS=$?

if [ $CIRCLE_CI_PASS -ne 1]; then
  echo "Circle CI not passed"
  exit 0
fi

if [ $JENKINS_CI_PASS -ne 1 ]; then
  echo "Jenkins CI not passed"
  exit 0
fi

if [ $INTEGRATION_TEST_PASS -ne 1 ]; then
  echo "Integration test not passed"
  exit 0
fi

echo "Okay, seems good, let's merge"
gh pr merge $GITHUB_PR_NUMBER -m -R $GITHUB_PR_SOURCE_REPO_OWNER/$REPO 

exit 0
