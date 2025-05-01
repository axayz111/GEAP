# GEAP
# 基因表达数据分析平台 | Gene Expression Analysis Platform

<div align="right">
  <a href="#chinese">中文</a> | <a href="#english">English</a>
</div>

<h2 id="chinese">中文说明</h2>

这是一个基于R Shiny的基因表达数据分析平台，用于处理和分析基因表达数据。

### 快速开始

1. 安装 [Docker](https://docs.docker.com/get-docker/)
2. 克隆此仓库
3. 运行启动脚本：
   - Windows: 双击运行 `start.bat`
   - Mac/Linux: 在终端中运行 `./start.sh`
4. 在浏览器中访问 http://localhost:3838

### 手动安装（可选）

如果您已经安装了R环境，也可以选择手动安装：

1. 确保已安装R和必要的包
2. 将原始数据文件放入 `data/raw/` 目录
3. 运行应用：
   ```bash
   ./run.sh
   ```
4. 在浏览器中访问 http://127.0.0.1:3838

### 项目结构

```
.
├── R/                      # R脚本文件
│   ├── step1_server.R     # 数据预处理服务器逻辑
│   └── step2_server.R     # LASSO分析服务器逻辑
├── data/                   # 数据目录
│   ├── raw/               # 原始数据
│   └── processed/         # 处理后的数据
├── output/                # 输出目录
│   ├── plots/            # 图形输出
│   └── results/          # 分析结果
├── www/                   # 静态文件
├── app.R                  # 主应用文件
├── Dockerfile            # Docker构建文件
├── docker-compose.yml    # Docker Compose配置
├── start.sh             # Unix启动脚本
├── start.bat            # Windows启动脚本
└── README.md            # 项目说明文件

### 数据文件要求

#### 训练数据集
- GSE61144_series_matrix.csv
- GSE61144_group_info.csv
- GSE61144_id2gene.csv

#### 验证数据集
- GSE59867_series_matrix.csv
- GSE59867_group_info.csv
- GSE59867_id2gene.csv

### 输出说明

- 处理后的数据将保存在 `data/processed/` 目录
- 图形输出将保存在 `output/plots/` 目录
- 分析结果将保存在 `output/results/` 目录

---

<h2 id="english">English Description</h2>

This is an R Shiny-based platform for processing and analyzing gene expression data.

### Quick Start

1. Install [Docker](https://docs.docker.com/get-docker/)
2. Clone this repository
3. Run the startup script:
   - Windows: Double-click `start.bat`
   - Mac/Linux: Run `./start.sh` in terminal
4. Visit http://localhost:3838 in your browser

### Manual Installation (Optional)

If you already have R installed, you can choose manual installation:

1. Ensure R and required packages are installed
2. Place raw data files in the `data/raw/` directory
3. Run the application:
   ```bash
   ./run.sh
   ```
4. Visit http://127.0.0.1:3838 in your browser

### Project Structure

```
.
├── R/                      # R script files
│   ├── step1_server.R     # Data preprocessing server logic
│   └── step2_server.R     # LASSO analysis server logic
├── data/                   # Data directory
│   ├── raw/               # Raw data
│   └── processed/         # Processed data
├── output/                # Output directory
│   ├── plots/            # Plot outputs
│   └── results/          # Analysis results
├── www/                   # Static files
├── app.R                  # Main application file
├── Dockerfile            # Docker build file
├── docker-compose.yml    # Docker Compose configuration
├── start.sh             # Unix startup script
├── start.bat            # Windows startup script
└── README.md            # Project documentation
```

### Data File Requirements

#### Training Dataset
- GSE61144_series_matrix.csv
- GSE61144_group_info.csv
- GSE61144_id2gene.csv

#### Validation Dataset
- GSE59867_series_matrix.csv
- GSE59867_group_info.csv
- GSE59867_id2gene.csv

### Output Description

- Processed data will be saved in the `data/processed/` directory
- Plots will be saved in the `output/plots/` directory
- Analysis results will be saved in the `output/results/` directory
