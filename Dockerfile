FROM google/dart

WORKDIR /app

ADD pubspec.* /app/
RUN pub get
ADD . /app
RUN pub get --offline
RUN mkdir -p storage

ENV VARIANT="network"
ENV MEMPOOL_AGE="10000"
ENV PORT="3000"
ENV STORAGE="./storage"
ENV NETWORK="konstantinullrich.de:8081"
ENV PRIVATE_KEY=""

ENTRYPOINT /usr/bin/dart bin/main.dart --variant=$VARIANT --mempool-age=$MEMPOOL_AGE --port=$PORT --storage=$STORAGE --network=$NETWORK --private-key=$PRIVATE_KEY
