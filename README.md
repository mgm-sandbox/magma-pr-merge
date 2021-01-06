Build locally

```
$ docker build -t mgm-pr-merge:latest
```

Run locally, test github and jenkins authentication
```
$ docker run -e GH_TOKEN=xxx -e JENKINS_URL=https://jenkins.company.ltd -e JENKINS_PASSWORD=jenkinsxxx -e JENKINS_USER=jenkins --rm -it mgm-pr-merge:latest /bin/sh
# gh auth status
github.com
  ✓ Logged in to github.com as xxx (GH_TOKEN)
  ✓ Git operations for github.com configured to use https protocol.
  ✓ Token: *******************
# java -jar /usr/bin/jenkins-cli.jar -auth "$JENKINS_USER:$JENKINS_PASSWORD" -s $JENKINS_URL -http who-am-i
Authenticated as: jenkins
Authorities:
  authenticated
```

How to test PR: 
```
$ docker run -e GITHUB_REPO_GIT_URL=git://github.com/mgm-sandbox/magma.git -e GITHUB_PR_SOURCE_REPO_OWNER=mgm-sandbox -e GITHUB_PR_NUMBER=4 -e GH_TOKEN=xxx -e JENKINS_URL=https://jenkins.company.ltd -e JENKINS_PASSWORD=jenkinsxxx -e JENKINS_USER=jenkins --rm -it mgm-pr-merge:latest /usr/bin/check_pr.sh
```
