# 👋 GEAP | Gene Expression Analysis Platform ✨

基因表达数据分析平台 || Gene Expression Analysis Platform || 遺伝子発現データ解析プラットフォーム
<div align="right">
  <a href="#chinese">中文 🇨🇳</a> | <a href="#english">English 🇺🇸</a> | <a href="#japanese">日本語 🇯🇵</a>
</div>
---
<img width="1694" alt="截屏2025-05-01 18 30 40" src="https://github.com/user-attachments/assets/a3add780-7889-4db3-8914-e2e3ed69c6e7" />
<img width="1715" alt="截屏2025-05-01 18 33 16" src="https://github.com/user-attachments/assets/84b28011-a39a-4c28-88da-8fb57f148444" />

---

<h2 id="chinese">中文说明 🇨🇳</h2>

🧬 准备好深入探索你的基因表达数据了吗！这是一个基于R Shiny的基因表达数据分析平台，帮你轻松处理和分析复杂的基因表达数据。🚀

原始 R 代码在 `R/` 目录。原始数据文件由于体积较大，暂时放在 [Google Drive](https://drive.google.com/drive/folders/1khtq8DXYEjKuLAExIOkuSYvaYQNyIoeV?usp=share_link) 中，请下载后按要求放置。

### 快速开始 🚀 (推荐)

想立即体验？Docker 帮你加速！

1. 安装 [Docker](https://docs.docker.com/get-docker/)
2. 克隆此仓库
3. **重要：** 将您的原始数据文件（见下方**数据文件要求**）放入克隆仓库的 `data/raw/` 目录。
4. 运行启动脚本：
    - Windows: 双击运行 `start.bat`
    - Mac/Linux: 在终端中运行 `./start.sh`
5. 在浏览器中访问 http://localhost:3838，开始你的分析之旅！🎉

### 手动安装 💪 (如果您是 R 爱好者)

如果您已经安装了 R 环境，并且喜欢自己动手：

1. 确保您的系统已安装 R 和脚本所需的所有 CRAN 包。
2. 将您的原始数据文件（见下方**数据文件要求**）放入克隆仓库的 `data/raw/` 目录。
3. 运行应用：
    ```bash
    ./run.sh
    ```
4. 在浏览器中访问 http://127.0.0.1:3838

### 项目结构 🏗️

```
├── R/                  # 存放 R 脚本文件 📜
│   ├── step1_server.R  # 数据预处理逻辑 ✨
│   └── step2_server.R  # LASSO 分析逻辑 🧠
├── data/               # 数据存放处 📁
│   ├── raw/            # 原始数据放这里 📥
│   └── processed/      # 处理后的数据在这里 😄
├── output/             # 分析结果和图表输出 📊
│   ├── plots/          # 美美的图都在这 📈📉
│   └── results/        # 分析报告和结果文件 📝
├── www/                # 静态文件目录 🖼️
├── app.R               # 应用主文件，一切从这里开始！▶️
├── Dockerfile          # Docker 构建蓝图 🐳
├── docker-compose.yml  # Docker 多容器编排（如果需要）🔗
├── start.sh            # Linux/Mac 启动脚本 🐧🍎
├── start.bat           # Windows 启动脚本 💻
└── README.md           # 你正在阅读的文件！📖
```

### 数据文件要求 📂

📊 数据分析就像烹饪，正确的“食材”是关键！您的原始数据需要符合以下格式，并放入 `data/raw/` 目录。所有文件都必须包含标题行。请仔细检查格式哦！😊

1.  **测量数据 (`*_data.csv`)**
    * 包含特征（如基因）在各样本的数值测量值。
    * 必需列: `id` (特征ID), `Sample1`, `Sample2`, ... (样本数据，数值或 "null")。
    * **重要：** 样本列的顺序必须与分组文件 (`*_group.csv`) 的行顺序**严格对应**！这很重要！ 👉
    * 示例:
        ```csv
        id,SampleA,SampleB,SampleC
        Probe_001,10.5,12.1,11.8
        Probe_002,5.2,null,5.5
        Probe_003,8.9,9.9,8.7
        ```

2.  **样本分组信息 (`*_group.csv`)**
    * 指定各样本的组别。
    * 必需列: `Group` (组别名称，如 "case", "control" 推荐)。
    * **行顺序必须严格与对应 `*_data.csv` 文件中的样本列顺序一致。** 再强调一次，顺序非常重要！ 🔄
    * 示例 (对应上述 SampleA, SampleB, SampleC):
        ```csv
        Group
        control
        case
        control
        ```

3.  **ID 到基因名映射 (`*_id_to_gene.csv`)**
    * 将特征 ID 映射到基因名称。
    * 必需列: `id` (特征ID，需与 `*_data.csv` 中的 `id` 列匹配), `gene` (基因名称)。
    * 脚本会处理基因名为空或重复的情况。
    * 示例:
        ```csv
        id,gene
        Probe_001,GeneX
        Probe_002,GeneY
        Probe_003,GeneZ
        ```

### 输出说明 ✨📊

分析完成后，结果会自动保存在以下目录：

-   处理后的数据将保存在 `data/processed/` 目录
-   图形输出将保存在 `output/plots/` 目录 🖼️
-   分析结果将保存在 `output/results/` 目录 📝

---

<h2 id="english">English Description 🇺🇸</h2>

🧬 Get ready to dive into your gene expression data! This R Shiny-based platform helps you easily process and analyze complex gene expression data. 🚀

The original R code is in the `R/` directory. The raw data files are currently hosted on [Google Drive](https://drive.google.com/drive/folders/1khtq8DXYEjKuLAExIOkuSYvaYQNyIoeV?usp=share_link) due to their size. Please download them and place them as required below.

### Quick Start 🚀 (Recommended)

Want to jump right in? Docker makes it lightning fast!

1. Install [Docker](https://docs.docker.com/get-docker/)
2. Clone this repository.
3. **Important:** Place your raw data files (see **Data File Requirements** below) into the `data/raw/` directory within the cloned repository.
4. Run the startup script:
    - Windows: Double-click `start.bat`
    - Mac/Linux: Run `./start.sh` in your terminal.
5. Visit http://localhost:3838 in your browser and start your analysis journey! 🎉

### Manual Installation 💪 (For the R Enthusiasts!)

If you already have an R environment set up and prefer a hands-on approach:

1. Ensure R and all necessary CRAN packages required by the scripts are installed on your system.
2. Place your raw data files (see **Data File Requirements** below) into the `data/raw/` directory within the cloned repository.
3. Run the application:
    ```bash
    ./run.sh
    ```
4. Visit http://127.0.0.1:3838 in your browser.

### Project Structure 🏗️

```
├── R/                  # R script files 📜
│   ├── step1_server.R  # Data preprocessing logic ✨
│   └── step2_server.R  # LASSO analysis logic 🧠
├── data/               # Data directory 📁
│   ├── raw/            # Put your raw data here 📥
│   └── processed/      # Processed data lives here 😄
├── output/             # Output directory for results and plots 📊
│   ├── plots/          # Your beautiful plots go here 📈📉
│   └── results/        # Analysis reports and result files 📝
├── www/                # Static files 🖼️
├── app.R               # Main application file, where the magic starts! ▶️
├── Dockerfile          # Docker build blueprint 🐳
├── docker-compose.yml  # Docker Compose config (if needed) 🔗
├── start.sh            # Unix startup script 🐧🍎
├── start.bat           # Windows startup script 💻
└── README.md           # The file you are reading! 📖
```

### Data File Requirements 📂

📊 Crunching data requires the right ingredients! Your raw data needs to match these formats and be placed in the `data/raw/` directory. All files must include a header row. Double-check those formats! 😉

1.  **Measurement Data (`*_data.csv`)**
    * Contains numerical measurements for features (like genes) in each sample.
    * Required Columns: `id` (Feature ID), `Sample1`, `Sample2`, ... (Sample data, numeric or "null").
    * **Important:** The order of sample columns must **strictly correspond** to the row order in the group file (`*_group.csv`)! This is crucial! 👉
    * Example:
        ```csv
        id,SampleA,SampleB,SampleC
        Probe_001,10.5,12.1,11.8
        Probe_002,5.2,null,5.5
        Probe_003,8.9,9.9,8.7
        ```

2.  **Sample Group Information (`*_group.csv`)**
    * Specifies the group for each sample.
    * Required Column: `Group` (Group name, e.g., "case", "control" recommended).
    * **Row order must strictly match the order of sample columns in the corresponding `*_data.csv` file.** Emphasizing this again, order is vital! 🔄
    * Example (corresponding to SampleA, SampleB, SampleC above):
        ```csv
        Group
        control
        case
        control
        ```

3.  **ID to Gene Mapping (`*_id_to_gene.csv`)**
    * Maps feature IDs to gene names.
    * Required Columns: `id` (Feature ID, must match `id` column in `*_data.csv`), `gene` (Gene name).
    * The script handles cases where gene names are empty or duplicated.
    * Example:
        ```csv
        id,gene
        Probe_001,GeneX
        Probe_002,GeneY
        Probe_003,GeneZ
        ```

### Output Description ✨📊

Once the analysis is complete, results will be automatically saved in the following directories:

-   Processed data will be saved in the `data/processed/` directory
-   Plots will be saved in the `output/plots/` directory 🖼️
-   Analysis results will be saved in the `output/results/` directory 📝

---

<h2 id="japanese">日本語の説明 🇯🇵</h2>

🧬 あなたの遺伝子発現データに飛び込む準備はいいですか！これはR Shinyベースのプラットフォームで、複雑な遺伝子発現データを簡単に処理・解析できます。🚀

オリジナルのRコードは `R/` ディレクトリにあります。生データファイルはサイズが大きいため、一時的に [Google Drive](https://drive.google.com/drive/folders/1khtq8DXYEjKuLAExIOkuSYvaYQNyIoeV?usp=share_link) にホストされています。ダウンロードして、以下の指示に従って配置してください。

### クイックスタート 🚀 (推奨)

すぐに試したいですか？Dockerを使えば超速スタートです！

1. [Docker](https://docs.docker.com/get-docker/) をインストールします。
2. このリポジトリをクローンします。
3. **重要：** クローンしたリポジトリ内の `data/raw/` ディレクトリに、生データファイル（以下の**データファイル要件**参照）を配置してください。
4. 起動スクリプトを実行します：
    - Windows: `start.bat` をダブルクリックして実行します。
    - Mac/Linux: ターミナルで `./start.sh` を実行します。
5. ブラウザで http://localhost:3838 にアクセスし、解析の旅を始めましょう！🎉

### 手動インストール 💪 (R愛好家向け！)

もしすでにR環境が整っていて、手動での構築を楽しみたい場合は：

1. システムに R およびスクリプトが必要とする全てのCRANパッケージがインストールされていることを確認します。
2. クローンしたリポジトリ内の `data/raw/` ディレクトリに、生データファイル（以下の**データファイル要件**参照）を配置してください。
3. アプリケーションを実行します：
    ```bash
    ./run.sh
    ```
4. ブラウザで http://127.0.0.1:3838 にアクセスします。

### プロジェクト構造 🏗️

```
├── R/                  # Rスクリプトファイル 📜
│   ├── step1_server.R  # データ前処理ロジック ✨
│   └── step2_server.R  # LASSO解析ロジック 🧠
├── data/               # データディレクトリ 📁
│   ├── raw/            # 生データはここに配置 📥
│   └── processed/      # 処理済みデータはこちら 😄
├── output/             # 解析結果およびグラフ出力 📊
│   ├── plots/          # 美しいグラフはこちら 📈📉
│   └── results/        # 解析レポートと結果ファイル 📝
├── www/                # 静的ファイル 🖼️
├── app.R               # メインアプリケーションファイル、ここから全てが始まります！▶️
├── Dockerfile          # Dockerビルドの設計図 🐳
├── docker-compose.yml  # Docker Compose設定（必要に応じて）🔗
├── start.sh            # Unix起動スクリプト 🐧🍎
├── start.bat           # Windows起動スクリプト 💻
└── README.md           # 今あなたが読んでいるファイルです！📖
```

### データファイル要件 📂

📊 データ解析は料理と同じ、正しい「食材」が肝心です！生データは以下のフォーマットに合致させ、`data/raw/` ディレクトリに配置する必要があります。全てのファイルにヘッダー行が必須です。フォーマットをよく確認してくださいね！ 😊

1.  **測定データ (`*_data.csv`)**
    * 各サンプルにおける特徴量（遺伝子など）の数値測定値を含みます。
    * 必須列: `id` (特徴量ID), `Sample1`, `Sample2`, ... (サンプルデータ、数値または "null")。
    * **重要：** サンプル列の順序は、グループファイル (`*_group.csv`) の行順と**厳密に一致**必須です！これは非常に重要です！ 👉
    * 例:
        ```csv
        id,SampleA,SampleB,SampleC
        Probe_001,10.5,12.1,11.8
        Probe_002,5.2,null,5.5
        Probe_003,8.9,9.9,8.7
        ```

2.  **サンプルグループ情報 (`*_group.csv`)**
    * 各サンプルのグループを指定します。
    * 必須列: `Group` (グループ名、例: "case", "control" 推奨)。
    * **行順は、対応する `*_data.csv` ファイルのサンプル列順と厳密に一致必須です。** もう一度強調しますが、順序は極めて重要です！ 🔄
    * 例 (上記の SampleA, SampleB, SampleC に対応):
        ```csv
        Group
        control
        case
        control
        ```

3.  **IDと遺伝子名の対応 (`*_id_to_gene.csv`)**
    * 特徴量IDを遺伝子名にマッピングします。
    * 必須列: `id` (特徴量ID、`*_data.csv` の `id` 列と一致必須), `gene` (遺伝子名)。
    * 遺伝子名が空または重複している場合もスクリプトが処理します。
    * 例:
        ```csv
        id,gene
        Probe_001,GeneX
        Probe_002,GeneY
        Probe_003,GeneZ
        ```

### 出力について ✨📊

解析が完了すると、結果は自動的に以下のディレクトリに保存されます：

-   処理済みデータは `data/processed/` ディレクトリに保存されます
-   グラフ出力は `output/plots/` ディレクトリに保存されます 🖼️
-   解析結果は `output/results/` ディレクトリに保存されます 📝

---
