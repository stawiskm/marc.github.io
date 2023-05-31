# Start from the official Debian image
FROM debian:latest

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
        curl \
        git \
        openssh-client \
        rsync \
        build-essential \
        nodejs \
        npm

# Install Go
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/go"
RUN apt-get install -y \
        wget \
        ca-certificates \
        gcc \
        libc6-dev \
        make \
        openssl \
        && wget -O go.tar.gz https://golang.org/dl/go1.18.4.linux-amd64.tar.gz \
        && tar -C /usr/local -xzf go.tar.gz \
        && rm go.tar.gz

# Verify Go installation
RUN go version

# Install Hugo
ENV HUGO_VERSION 0.109.0
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
RUN curl -Ls "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY}" -o /tmp/hugo.tar.gz && \
    tar -xzf /tmp/hugo.tar.gz -C /tmp && \
    mv /tmp/hugo /usr/local/bin/hugo && \
    rm /tmp/hugo.tar.gz

# Verify Hugo installation
RUN hugo version

# Verify Node.js and npm installation
RUN node -v
RUN npm -v

# Set the working directory
WORKDIR /app

# Copy the application code to the container
COPY . /app

# Install Hugo modules and tidy
# RUN hugo mod init
RUN hugo mod tidy

# Pack Hugo modules with npm and install dependencies
RUN hugo mod npm pack
RUN npm install

# Define the command to run your application
CMD [ "hugo", "server", "-w" ,"--disableFastRender" ,"--bind", "0.0.0.0" ]
