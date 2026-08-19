FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y lib32stdc++6 lib32z1 wget tar && rm -rf /var/lib/apt/lists/*
WORKDIR /server
COPY . .
RUN chmod +x ./samp03svr
EXPOSE 7777/udp
CMD ["./samp03svr"]

