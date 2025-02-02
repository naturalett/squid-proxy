docker build -t squid:authentication -f Dockerfile .

aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 818560237890.dkr.ecr.us-east-1.amazonaws.com

docker tag squid:authentication 818560237890.dkr.ecr.us-east-1.amazonaws.com/squid:authentication

docker push 818560237890.dkr.ecr.us-east-1.amazonaws.com/squid:authentication
