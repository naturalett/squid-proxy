# Use Ubuntu base image
FROM --platform=linux/amd64 ubuntu:20.04

# Set noninteractive mode for apt commands
ENV DEBIAN_FRONTEND=noninteractive

# Install Squid and other required tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    squid \
    apache2-utils \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy squid conf
COPY squid.conf /etc/squid/squid.conf

# Set default values for username and password
ENV SQUID_USER=admin
ENV SQUID_PASS=test

# Create password file for basic authentication
RUN htpasswd -bc /etc/squid/passwd $SQUID_USER $SQUID_PASS

# Expose the Squid port
EXPOSE 3128

# Run Squid in foreground
CMD ["squid", "-N"]
