#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# 切换到脚本所在目录
cd "$SCRIPT_DIR"
echo "当前工作目录: $(pwd)"

# 清理可能存在的旧进程
echo "清理旧进程..."
pkill -f "R -e shiny::runApp"

# 等待进程完全关闭
sleep 2

# 设置R内存限制
export R_MAX_VSIZE=8G
export R_MAX_NUM_DLLS=150

# 检查R包
echo "检查R包..."
R -e "
packages <- c(
    'shiny',
    'conflicted',
    'ggplot2',
    'dplyr',
    'readr',
    'factoextra',
    'tidyr',
    'umap',
    'limma',
    'VennDiagram',
    'scales',
    'spatstat.geom',
    'tidyverse',
    'ggpubr',
    'Cairo',
    'glmnet',
    'readxl',
    'openxlsx',
    'tibble',
    'shinyjs',
    'colourpicker'
)

for(pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        message(paste('Installing package:', pkg))
        install.packages(pkg, repos='https://cloud.r-project.org')
    }
}
"

# 设置R环境变量
export R_LIBS_USER=~/R/x86_64-pc-linux-gnu-library/4.0

# 启动R应用
echo "正在启动应用..."
R -e "message('开始启动应用...'); shiny::runApp('app.R', port = 3838, host = '127.0.0.1', launch.browser = TRUE, display.mode = 'normal')" 