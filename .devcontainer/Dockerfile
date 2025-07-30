# Use official Julia base image
FROM julia:1.10

# Create a non-root user
RUN useradd -m vscode && \
    apt-get update && apt-get install -y curl git unzip && \
    chown -R vscode:vscode /home/vscode

USER vscode
WORKDIR /home/vscode

WORKDIR /workspace
