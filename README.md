# GEAP
# | Gene Expression Analysis Analysis Platform | 
 基因表达数据分析平台 || 遺伝子発現データ解析プラットフォーム
<div align="right">
  <a href="#chinese">中文</a> | <a href="#english">English</a> | <a href="#japanese">日本語</a>
</div>

<h2 id="chinese">中文说明</h2>

这是一个基于R Shiny的基因表达数据分析平台，用于处理和分析基因表达数据。
<img width="1694" alt="截屏2025-05-01 18 30 40" src="https://github.com/user-attachments/assets/a3add780-7889-4db3-8914-e2e3ed69c6e7" />
<img width="1715" alt="截屏2025-05-01 18 33 16" src="https://github.com/user-attachments/assets/84b28011-a39a-4c28-88da-8fb57f148444" />

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

├── R/                      # R脚本文件
│   ├── step1_server.R     # 数据预处理服务器逻辑
│   └── step2_server.R     # LASSO分析服务器逻辑
├── data/                   # 数据目录
│   ├── raw/               # 原始数据
│   └── processed/         # 处理后的数据
├── output/                # 输出目录
│   ├── plots/            # 图形输出
│   └── results/          # 分析结果
├── www/                   # 静态文件
├── app.R                  # 主应用文件
├── Dockerfile            # Docker构建文件
├── docker-compose.yml    # Docker Compose配置
├── start.sh             # Unix启动脚本
├── start.bat            # Windows启动脚本
└── README.md            # 项目说明文件
```

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
├── R/                      # R script files
│   ├── step1_server.R     # Data preprocessing server logic
│   └── step2_server.R     # LASSO analysis server logic
├── data/                   # Data directory
│   ├── raw/               # Raw data
│   └── processed/         # Processed data
├── output/                # Output directory
│   ├── plots/            # Plot outputs
│   └── results/          # Analysis results
├── www/                   # Static files
├── app.R                  # Main application file
├── Dockerfile            # Docker build file
├── docker-compose.yml    # Docker Compose configuration
├── start.sh             # Unix startup script
├── start.bat            # Windows startup script
└── README.md            # Project documentation
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

---

<h2 id="japanese">日本語の説明</h2>

これは、遺伝子発現データを処理および解析するためのR Shinyベースのプラットフォームです。

### クイックスタート

1. [Docker](https://docs.docker.com/get-docker/) をインストールします
2. このリポジトリをクローンします
3. 起動スクリプトを実行します：
   - Windows: `start.bat` をダブルクリックして実行します
   - Mac/Linux: ターミナルで `./start.sh` を実行します
4. ブラウザで http://localhost:3838 にアクセスします

### 手動インストール（オプション）

R環境がすでにインストールされている場合は、手動インストールを選択することもできます：

1. Rと必要なパッケージがインストールされていることを確認します
2. 生データファイルを `data/raw/` ディレクトリに配置します
3. アプリケーションを実行します：
   ```bash
   ./run.sh
   ```
4. ブラウザで http://127.0.0.1:3838 にアクセスします

### プロジェクト構造

```
├── R/                      # R script files (Rスクリプトファイル)
│   ├── step1_server.R     # Data preprocessing server logic (データ前処理サーバーロジック)
│   └── step2_server.R     # LASSO analysis server logic (LASSO解析サーバーロジック)
├── data/                   # Data directory (データディレクトリ)
│   ├── raw/               # Raw data (生データ)
│   └── processed/         # Processed data (処理済みデータ)
├── output/                # Output directory (出力ディレクトリ)
│   ├── plots/            # Plot outputs (グラフ出力)
│   └── results/          # Analysis results (解析結果)
├── www/                   # Static files (静的ファイル)
├── app.R                  # Main application file (メインアプリケーションファイル)
├── Dockerfile            # Docker build file (Dockerビルドファイル)
├── docker-compose.yml    # Docker Compose configuration (Docker Compose設定)
├── start.sh             # Unix startup script (Unix起動スクリプト)
├── start.bat            # Windows startup script (Windows起動スクリプト)
└── README.md            # Project documentation (プロジェクトドキュメント)
```
*Note: Japanese translations are added in parentheses for clarity.*

### データファイル要件

#### トレーニングデータセット
- GSE61144_series_matrix.csv
- GSE61144_group_info.csv
- GSE61144_id2gene.csv

#### 検証データセット
- GSE59867_series_matrix.csv
- GSE59867_group_info.csv
- GSE59867_id2gene.csv

### 出力について

- 処理済みデータは `data/processed/` ディレクトリに保存されます
- グラフ出力は `output/plots/` ディレクトリに保存されます
- 解析結果は `output/results/` ディレクトリに保存されます

