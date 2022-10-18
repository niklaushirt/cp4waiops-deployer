FROM node:erbium-alpine

ENV RELEASE_VERSION=0.13.05 


RUN apk add --update bash
RUN apk add stress-ng
RUN rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*


RUN mkdir /app
WORKDIR /app

COPY app.js . 
COPY LICENSE .
COPY package.json .
COPY README.md .
COPY views ./views
COPY public ./public

RUN apk --no-cache --virtual build-dependencies add \
    python3 \
    make \
    g++ 
RUN npm install
RUN npm audit fix 
RUN apk del build-dependencies

RUN chmod 777 /app
EXPOSE 3000

CMD ["node", "app.js"]
