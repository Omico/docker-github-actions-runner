FROM ubuntu:22.04

ARG RUNNER_NAME
ARG RUNNER_GROUP
ARG RUNNER_VERSION
ARG RUNNER_URL
ARG RUNNER_TOKEN

ENV LC_ALL=C.UTF-8

WORKDIR /actions-runner

RUN apt update -y && apt upgrade -y

RUN apt install -y \
    curl \
    git

RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt update \
    && apt install gh -y

RUN curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz
RUN tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && rm actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

RUN ./bin/installdependencies.sh

RUN useradd -m actions
RUN chown -R actions:actions /actions-runner
USER actions

RUN ./config.sh \
    --unattended \
    --replace \
    --name "${RUNNER_NAME}" \
    --runnergroup ${RUNNER_GROUP} \
    --url "${RUNNER_URL}" \
    --token "${RUNNER_TOKEN}"

CMD ["./run.sh"]
