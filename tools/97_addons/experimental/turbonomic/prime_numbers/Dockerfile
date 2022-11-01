FROM node:14

WORKDIR /app
COPY package.json /app
RUN npm install
COPY ./*.js /app/
# At the end, set the user to use when running this image

USER node

EXPOSE 8080
CMD node index.js