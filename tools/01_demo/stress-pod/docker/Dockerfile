FROM ubuntu:20.10

WORKDIR /app

RUN apt-get update && apt-get install -y nano python3-pip htop stress-ng

COPY stress.job /app/stress.job

ENTRYPOINT stress-ng --job /app/stress.job
