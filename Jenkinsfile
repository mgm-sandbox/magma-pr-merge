// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: magmasandbox/mgm-pr-merge:master
    imagePullPolicy: Always
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'shell'
        }
    }
    stages {
        stage('Check and merge PR') {
            steps {
                sh 'gh auth status'
                sh 'java -jar /usr/bin/jenkins-cli.jar -auth "$JENKINS_USER:$JENKINS_PASSWORD" -s $JENKINS_URL -http who-am-i'
                sh '/usr/bin/check_pr.sh'
            }
        }
    }
}

