FROM mongo:4.0-xenial

#Var from docker-compose to DockerFile
ENV PORT_MONGO=27017
EXPOSE $PORT_MONGO
# Copying files
WORKDIR /scripts
COPY /scripts .
RUN chmod -R +x .
CMD ["sh", "init.sh"]
