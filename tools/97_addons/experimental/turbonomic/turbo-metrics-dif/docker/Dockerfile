FROM node:14-alpine
WORKDIR /app

ENV NODE_ENV production

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001

# You only need to copy next.config.js if you are NOT using the default configuration
COPY package.json package.json
RUN npm install

USER nextjs

COPY server.js server.js

ENV RESPTIME_MIN_1 50
ENV RESPTIME_MIN_2 200
ENV RESPTIME_AVG_1 200
ENV RESPTIME_AVG_2 500
ENV RESPTIME_MAX_1 500
ENV RESPTIME_MAX_2 2000
ENV TRANSACTION_MIN_1 50
ENV TRANSACTION_MIN_2 100
ENV TRANSACTION_AVG_1 100
ENV TRANSACTION_AVG_2 200
ENV TRANSACTION_MAX_1 200
ENV TRANSACTION_MAX_2 300

EXPOSE 3000

CMD [ "node", "server.js" ]