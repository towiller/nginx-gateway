FROM openresty/openresty:latest
# 安装依赖项
RUN apt-get update && apt-get install -y libpcre3-dev luarocks
# RUN luarocks install opm
# 复制代码到容器中
COPY ./config/ /usr/local/openresty/nginx/conf
# 暴露端口
EXPOSE 80 443
# 定义容器启动命令
CMD ["nginx", "-g", "daemon off;"]