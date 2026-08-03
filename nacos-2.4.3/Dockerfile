FROM nacos/nacos-server:v2.4.3

USER root

RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

USER nacos
