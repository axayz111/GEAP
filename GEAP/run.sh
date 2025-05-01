#!/bin/bash

# 设置语言环境
LANG_CN="true"  # 默认使用中文

# 双语提示函数
show_message() {
    if [ "$LANG_CN" = "true" ]; then
        echo "$1"
    else
        echo "$2"
    fi
}

# 检查R是否安装
if ! command -v R &> /dev/null; then
    show_message "错误: R未安装，请先安装R" "Error: R is not installed. Please install R first"
    exit 1
fi

# 检查必要目录是否存在
show_message "检查目录结构..." "Checking directory structure..."

# 创建必要的目录
mkdir -p R data/{raw,processed} output/{plots,results} www

# 检查必要文件是否存在
show_message "检查必要文件..." "Checking required files..."

if [ ! -f "R/step1_server.R" ]; then
    show_message "错误: R/step1_server.R 文件不存在" "Error: R/step1_server.R file does not exist"
    exit 1
fi

if [ ! -f "R/step2_server.R" ]; then
    show_message "错误: R/step2_server.R 文件不存在" "Error: R/step2_server.R file does not exist"
    exit 1
fi

if [ ! -f "app.R" ]; then
    show_message "错误: app.R 文件不存在" "Error: app.R file does not exist"
    exit 1
fi

# 设置文件权限
show_message "设置文件权限..." "Setting file permissions..."
chmod +x run.sh
chmod 644 app.R R/step1_server.R R/step2_server.R

# 显示当前工作目录和文件列表
show_message "当前工作目录: $(pwd)" "Current working directory: $(pwd)"
show_message "目录内容:" "Directory contents:"
ls -la

# 检查并安装必要的R包
show_message "检查R包..." "Checking R packages..."
R -e '
packages <- c(
    "shiny",
    "ggplot2",
    "dplyr",
    "readr",
    "factoextra",
    "tidyr",
    "umap",
    "limma",
    "VennDiagram",
    "scales",
    "spatstat.geom",
    "tidyverse",
    "ggpubr",
    "Cairo",
    "glmnet",
    "readxl",
    "openxlsx",
    "tibble"
)

for(pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        message(paste("Installing package:", pkg))
        install.packages(pkg, repos="https://cloud.r-project.org")
    }
}
'

# 启动Shiny应用
show_message "启动Shiny应用..." "Starting Shiny application..."
show_message "请在浏览器中访问 http://127.0.0.1:3838" "Please visit http://127.0.0.1:3838 in your browser"
R -e "shiny::runApp('app.R', port = 3838, host = '127.0.0.1', launch.browser = TRUE)" 