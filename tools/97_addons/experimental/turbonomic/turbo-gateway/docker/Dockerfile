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

ENV POLLING_INTERVAL 10
ENV TURBO_USER apiuser
ENV TURBO_PWD your-password
ENV TURBO_API_URL api-turbonomic.xyz.eu-de.containers.appdomain.cloud
ENV TURBO_BA_NAME RobotShop
ENV NOI_SUMMARY_PREFIX [Turbonomic] 
ENV NOI_WEBHOOK_URL netcool-evtmanager.xyz.eu-de.containers.appdomain.cloud
ENV NOI_WEBHOOK_PATH /norml/webhook/webhookincomming/xxx-yyy-zzz/aaaa
ENV DEBUG_ENABLED false
ENV ENTITY_TYPES 'VirtualMachine,Application,PhysicalMachine,ContainerSpec,WorkloadController,Container'
ENV ACTION_TYPES 'MOVE,RESIZE_FOR_PERFORMANCE,RESIZE_FOR_EFFICIENCY,RESIZE'
ENV ACTION_STATES 'SUCCEEDED,FAILED,READY,IN_PROGRESS'

EXPOSE 3000

CMD [ "node", "server.js" ]