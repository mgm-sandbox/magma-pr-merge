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


