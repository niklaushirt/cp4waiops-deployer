FROM python:3.8   
ENV HOME_DIR=/home/app/  

# set work directory  
RUN mkdir -p $HOME_DIR  

# where your code lives  
WORKDIR $HOME_DIR  

# set environment variables  
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1  



# install dependencies  
RUN pip install --upgrade pip  
RUN pip install confluent-kafka

# Install Openshift Client
RUN wget https://github.com/openshift/okd/releases/download/4.9.0-0.okd-2022-01-14-230113/openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && tar xfvz openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz && mv oc /usr/local/bin && mv kubectl /usr/local/bin/ && rm openshift-client-linux-4.9.0-0.okd-2022-01-14-230113.tar.gz

RUN apt update && apt install -y jq && rm -rf /var/lib/apt/lists/*


# copy whole project to your docker home directory. 
COPY ./CODE $HOME_DIR  
# run this command to install all dependencies  
RUN pip install -r requirements.txt  

# port where the Django app runs  
EXPOSE 8000  
# start server  
CMD python main.py