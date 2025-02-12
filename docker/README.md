# Squid Proxy with SSL and Authentication

This repository provides a Dockerized setup for a Squid proxy server configured with SSL support and authentication.

## Build Steps
To build the Docker image for Squid:

```sh
cd squid-proxy/docker
docker build -t squid:ssl-passwd -f Dockerfile .
```

## Run and Test
Run the Squid container:

```sh
docker run -d --name squid-container -it -p 3128:3128 squid:ssl-passwd
```

### Test the Proxy
#### Without Authentication
```sh
curl -I --proxy http://localhost:3128 https://www.google.com
```

#### With Authentication
```sh
curl -I --proxy-user admin:test --proxy http://localhost:3128 https://www.google.com
```

## Pushing the Docker Image to AWS ECR

### Login to AWS ECR
Replace `1234` with your actual AWS account ID:

```sh
export AWS_ACCOUNT="1234"
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com
```

### Tag the Docker Image
```sh
docker tag squid:ssl-passwd $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/squid:ssl-passwd
```

### Push the Docker Image
```sh
docker push $AWS_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/squid:ssl-passwd
```

## Contact
For questions or contributions, feel free to open an issue or submit a pull request.

---

⭐ **Follow me for more DevOps content:** [https://www.top10devops.com/](https://www.top10devops.com/) 🚀

