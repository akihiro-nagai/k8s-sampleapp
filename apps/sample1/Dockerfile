FROM google/cloud-sdk:373.0.0

RUN apt-get update && \
    apt-get upgrade -y
RUN apt-get install -y \
      nginx \
      vim \
      procps

ENTRYPOINT ["nginx", "-g", "daemon off;"]
