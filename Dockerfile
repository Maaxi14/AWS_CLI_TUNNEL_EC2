FROM amazonlinux:latest

RUN yum update -y && \
    yum install -y jq less && \
    yum clean all

WORKDIR /app

COPY ec2-tunnel.sh .

RUN chmod +x ec2-tunnel.sh

ENTRYPOINT ["/app/ec2-tunnel.sh"]