FROM amazonlinux:2

RUN yum -y install tar \
    gzip \
    awscli \
    postgresql

WORKDIR /app

ADD run.sh .
RUN chmod +x run.sh
CMD /app/run.sh