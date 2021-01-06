FROM alpine:3.12.3 as builder
ARG GH_VERSION="1.4.0"
ARG JENKINS_URL="https://jenkins.mgm.metacoma.io"

RUN apk add --update wget
WORKDIR /tmp
RUN wget -O - https://github.com/cli/cli/releases/download/v1.4.0/gh_${GH_VERSION}_linux_amd64.tar.gz | tar zxvf - 
RUN wget -O /usr/bin/jenkins-cli.jar $JENKINS_URL/jnlpJars/jenkins-cli.jar
RUN cp /tmp/gh_${GH_VERSION}_linux_amd64/bin/gh /usr/bin

FROM alpine:3.12.3 
RUN apk add --update libc6-compat jq openjdk11-jre
COPY --from=builder /usr/bin/gh /usr/bin/gh
COPY --from=builder /usr/bin/jenkins-cli.jar /usr/bin/jenkins-cli.jar
#why it not working??
#ADD https://$JENKINS_URL/jnlpJars/jenkins-cli.jar /usr/bin
