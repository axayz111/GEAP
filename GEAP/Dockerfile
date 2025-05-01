FROM rocker/shiny:latest

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libcairo2-dev \
    libxt-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装R包
RUN R -e "install.packages(c(\
    'shiny', \
    'ggplot2', \
    'dplyr', \
    'readr', \
    'factoextra', \
    'tidyr', \
    'umap', \
    'limma', \
    'VennDiagram', \
    'scales', \
    'spatstat.geom', \
    'tidyverse', \
    'ggpubr', \
    'Cairo', \
    'glmnet', \
    'readxl', \
    'openxlsx', \
    'tibble' \
    ), repos='https://cloud.r-project.org/')"

# 创建应用目录
RUN mkdir -p /app/data/raw /app/data/processed /app/output/plots /app/output/results /app/www /app/R

# 复制应用文件
COPY app.R /app/
COPY R/ /app/R/
COPY www/ /app/www/

# 设置工作目录
WORKDIR /app

# 设置权限
RUN chmod -R 777 /app

# 暴露端口
EXPOSE 3838

# 启动应用
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"] 