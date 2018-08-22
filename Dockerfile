FROM python

# Set Proxy
ENV http_proxy http://168.219.61.252:8080/
ENV https_proxy https://168.219.61.252:8080/
ENV no_proxy "127.0.0.1,localhost,165.213.180.*,168.219.61.*"

ENV PYTHONUNBUFFERED 1
RUN mkdir /code
WORKDIR /code
RUN pip install -i http://pypi.gocept.com/simple --trusted-host pypi.gocept.com django
RUN pip install -i http://pypi.gocept.com/simple --trusted-host pypi.gocept.com psycopg2-binary
RUN pip install -i http://pypi.gocept.com/simple --trusted-host pypi.gocept.com mysqlclient

# add user : modify user ID & user name for you
ARG USER_ID
ENV USER_ID ${USER_ID}
ARG USER_NAME
ENV USER_NAME ${USER_NAME}
RUN useradd -u $USER_ID -ms /bin/bash $USER_NAME
