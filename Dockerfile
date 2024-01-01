FROM ubuntu:22.10 as DOWNLOADER
RUN mkdir -p /usr/app
WORKDIR /usr/app
ENV KUBE_CAPACITY_VERSION="0.7.4"
ENV VECTOR_VERSION="0.34.1"
ENV KUBECTL_VERSION="1.27.0"
RUN apt update && \
    apt install -y curl
COPY . .
RUN mkdir -p /usr/app/bin
RUN mkdir -p /usr/app/tmp
# Download kube-capacity
RUN curl -sLo tmp/kube-capacity.tar.gz https://github.com/robscott/kube-capacity/releases/download/v${KUBE_CAPACITY_VERSION}/kube-capacity_${KUBE_CAPACITY_VERSION}_Linux_x86_64.tar.gz && \
    cd tmp && \
    tar -xf kube-capacity.tar.gz && \
    cd .. && \
    mv tmp/kube-capacity bin/kube-capacity && \
    chmod +x bin/kube-capacity
# Download vector
RUN curl -sLo tmp/vector.tar.gz https://packages.timber.io/vector/${VECTOR_VERSION}/vector-${VECTOR_VERSION}-x86_64-unknown-linux-gnu.tar.gz && \
    cd tmp && \
    tar -xf vector.tar.gz && \
    cd .. && \
    mv tmp/vector-x86_64-unknown-linux-gnu/bin/vector bin/vector && \
    chmod +x bin/vector
# DOWNLOAD kubectl
RUN curl -sLo bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    chmod +x bin/kubectl

FROM ubuntu:22.10
RUN mkdir -p /usr/app
WORKDIR /usr/app
RUN apt update && \
    apt install -y jq unzip curl bc
RUN mkdir -p /usr/app/scripts
RUN mkdir -p /usr/app/vector
COPY --from=DOWNLOADER /usr/app/bin/ /usr/app/bin/
COPY docker-entrypoint.sh /usr/app/docker-entrypoint.sh
RUN install bin/kube-capacity /usr/local/bin/kube-capacity && \
    install bin/kubectl /usr/local/bin/kubectl && \
    install bin/vector /usr/local/bin/vector
RUN curl -sLo awscliv2.zip "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" && \
    unzip awscliv2.zip && \
    ./aws/install --bin-dir /usr/local/bin --install-dir /usr/local/aws-cli --update && \
    rm awscliv2.zip && \
    rm -rf aws
ENTRYPOINT ["/usr/app/docker-entrypoint.sh"]
