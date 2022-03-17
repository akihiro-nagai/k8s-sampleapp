FROM google/cloud-sdk:373.0.0

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y \
      nginx \
      vim \
      procps

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
#ENTRYPOINT ["nginx", "-g", "daemon off;"]
