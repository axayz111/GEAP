# =====================================================
# 基因表达数据分析平台 - 主应用程序
# 作者：[您的名字]
# 最后更新：2024-05-01
# 描述：此文件是应用程序的主入口，整合了数据预处理和LASSO回归分析功能
# =====================================================

# ==== 第一部分：初始化设置 ====
# 创建应用环境
app.env <- new.env()

# 加载包管理模块（使用本地环境）
source("./R/load_packages.R", local = app.env)

# 加载shinyFiles包
library(shinyFiles)

# 解决colourInput函数冲突
conflicts_prefer(colourpicker::colourInput)

# 加载服务器端逻辑
source("./R/step1_server.R", local = app.env)
source("./R/step2_server.R", local = app.env)

# 设置工作目录（非交互模式下）
if (!interactive()) {
  script_path <- commandArgs(trailingOnly = FALSE)
  script_path <- script_path[grep("--file=", script_path)]
  if (length(script_path) > 0) {
    script_path <- substring(script_path, 8)
    setwd(dirname(script_path))
  }
}

# ==== 第二部分：目录和文件检查 ====
dirs <- c("data/raw", "data/processed", "output/plots", "output/results", "www")
for (dir in dirs) {
  if (!dir.exists(dir)) {
    dir.create(dir, recursive = TRUE)
  }
}

if (!file.exists("./R/step1_server.R") || !file.exists("./R/step2_server.R")) {
  stop("服务器文件不存在，请确保 R/step1_server.R 和 R/step2_server.R 文件在当前目录中")
}

# ==== 第三部分：用户界面文本定义 ====
ui_text <- list(
  cn = list(
    title = "基因表达数据分析平台",
    tab1 = "数据预处理",
    tab2 = "LASSO回归分析",
    input_files = "输入文件",
    output_settings = "输出设置",
    pdf_settings = "PDF绘图设置",
    run_button = "运行处理",
    processing_output = "处理输出",
    train_data = "训练数据路径 (.csv):",
    valid_data = "验证数据路径 (.csv):",
    output_dir = "输出目录:",
    pdf_width = "PDF宽度 (英寸):",
    pdf_height = "PDF高度 (英寸):",
    lasso_settings = "LASSO设置",
    fixed_lambda = "固定λ值:",
    run_analysis = "运行分析",
    analysis_output = "分析输出"
  ),
  en = list(
    title = "Gene Expression Analysis Platform",
    tab1 = "Data Preprocessing",
    tab2 = "LASSO Regression Analysis",
    input_files = "Input Files",
    output_settings = "Output Settings",
    pdf_settings = "PDF Plot Settings",
    run_button = "Run Processing",
    processing_output = "Processing Output",
    train_data = "Training Data Path (.csv):",
    valid_data = "Validation Data Path (.csv):",
    output_dir = "Output Directory:",
    pdf_width = "PDF Width (inches):",
    pdf_height = "PDF Height (inches):",
    lasso_settings = "LASSO Settings",
    fixed_lambda = "Fixed λ Value:",
    run_analysis = "Run Analysis",
    analysis_output = "Analysis Output"
  )
)

# ==== 第四部分：用户界面定义 ====
ui <- function(request) {
  fluidPage(
    tags$head(
      tags$style(HTML("
        /* 动态背景 */
        @keyframes gradient {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        
        body {
          background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
          background-size: 400% 400%;
          animation: gradient 15s ease infinite;
          min-height: 100vh;
          margin: 0;
          padding: 20px;
          font-family: 'Arial', sans-serif;
        }
        
        /* 毛玻璃效果容器 */
        .glass-container {
          background: rgba(255, 255, 255, 0.2);
          backdrop-filter: blur(10px);
          border-radius: 15px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.3);
          padding: 20px;
          margin: 10px;
        }
        
        /* 文件选择器样式 */
        .file-input-container {
          position: relative;
          overflow: hidden;
          display: inline-block;
          width: 100%;
        }
        
        .file-input-button {
          background: rgba(255, 255, 255, 0.3);
          border: 1px solid rgba(255, 255, 255, 0.5);
          border-radius: 10px;
          padding: 8px 15px;
          cursor: pointer;
          width: 100%;
          text-align: left;
          margin-bottom: 10px;
        }
        
        .file-input-button:hover {
          background: rgba(255, 255, 255, 0.4);
        }
        
        /* 文件输入框样式 */
        .shiny-input-container {
          width: 100% !important;
        }
        
        .shiny-file-input-progress {
          display: none;
        }
        
        /* 颜色选择器样式 */
        .color-picker-container {
          display: flex;
          align-items: center;
          margin-bottom: 10px;
        }
        
        .color-picker-label {
          margin-right: 10px;
          min-width: 100px;
        }
        
        .color-picker {
          flex: 1;
        }
        
        /* 预览图样式 */
        .preview-container {
          background: rgba(255, 255, 255, 0.3);
          border-radius: 10px;
          padding: 15px;
          margin: 10px 0;
        }
        
        .preview-image {
          max-width: 100%;
          height: auto;
          border-radius: 5px;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        /* 导航栏样式 */
        .navbar {
          background: rgba(255, 255, 255, 0.2) !important;
          backdrop-filter: blur(10px);
          border-radius: 15px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.3);
          margin-bottom: 20px !important;
        }
        
        /* 侧边栏面板样式 */
        .well {
          background: rgba(255, 255, 255, 0.2) !important;
          backdrop-filter: blur(10px);
          border-radius: 15px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.3);
        }
        
        /* 主面板样式 */
        .main-panel {
          background: rgba(255, 255, 255, 0.2);
          backdrop-filter: blur(10px);
          border-radius: 15px;
          box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
          border: 1px solid rgba(255, 255, 255, 0.3);
          padding: 20px;
          margin: 10px;
        }
        
        /* 按钮样式 */
        .btn {
          background: rgba(255, 255, 255, 0.3) !important;
          backdrop-filter: blur(5px);
          border-radius: 10px !important;
          border: 1px solid rgba(255, 255, 255, 0.5) !important;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
          transition: all 0.3s ease !important;
          color: #333 !important;
        }
        
        .btn:hover {
          background: rgba(255, 255, 255, 0.4) !important;
          transform: translateY(-2px);
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        .btn:active {
          transform: translateY(1px);
          box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }
        
        /* 输入框样式 */
        .form-control {
          background: rgba(255, 255, 255, 0.3) !important;
          backdrop-filter: blur(5px);
          border-radius: 10px !important;
          border: 1px solid rgba(255, 255, 255, 0.5) !important;
          box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .form-control:focus {
          background: rgba(255, 255, 255, 0.4) !important;
          box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
        }
        
        /* 标题样式 */
        h3, h4 {
          color: #333;
          text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }
        
        /* 语言切换按钮样式 */
        .language-button {
          position: absolute;
          top: 10px;
          right: 10px;
          z-index: 1000;
        }
        
        .language-button .btn {
          background: rgba(51, 122, 183, 0.8) !important;
          color: white !important;
          border: none !important;
        }
        
        /* 下载按钮样式 */
        .download-button {
          background: rgba(92, 184, 92, 0.8) !important;
          color: white !important;
          border: none !important;
          margin: 5px;
        }
        
        .download-button:hover {
          background: rgba(92, 184, 92, 0.9) !important;
        }
      "))
    ),
    useShinyjs(),
    div(
      class = "language-button",
      actionButton("toggle_lang", "中文 | English",
                   style = "color: #fff; background-color: #337ab7; border-color: #2e6da4;")
    ),
    div(class = "glass-container",
      uiOutput("main_ui")
    )
  )
}

# ==== 第五部分：服务器逻辑 ====
server <- function(input, output, session) {
  # 创建服务器环境
  server.env <- new.env(parent = app.env)
  
  # 加载服务器模块到服务器环境
  source("./R/step1_server.R", local = server.env)
  source("./R/step2_server.R", local = server.env)
  
  # 将服务器环境中的函数复制到当前环境
  for (name in ls(server.env)) {
    assign(name, get(name, envir = server.env), envir = environment())
  }

  lang <- reactiveVal("cn")

  observeEvent(input$toggle_lang, {
    lang(ifelse(lang() == "cn", "en", "cn"))
  })

  # 文件选择器处理
  observeEvent(input$select_file, {
    file <- input$select_file
    if (!is.null(file)) {
      updateTextInput(session, "selected_file_path", value = file$datapath)
    }
  })

  # 颜色选择器处理
  observeEvent(input$color_picker, {
    updateTextInput(session, "selected_color", value = input$color_picker)
  })

  # 目录选择器处理
  volumes <- c(Home = path.expand("~"), "R Installation" = R.home(), getVolumes()())
  shinyDirChoose(input, "output_dir", roots = volumes, session = session)

  output$main_ui <- renderUI({
    current_lang <- lang()
    txt <- ui_text[[current_lang]]

    navbarPage(
      title = txt$title,
      id = "navbar",
      tabPanel(txt$tab1,
        sidebarLayout(
          sidebarPanel(
            h4(txt$input_files),
            div(class = "file-input-container",
              actionButton("browse_train_data", "浏览训练数据文件", class = "file-input-button"),
              fileInput("train_data_file", "", accept = c(".csv"))
            ),
            div(class = "file-input-container",
              actionButton("browse_train_group", "浏览训练分组文件", class = "file-input-button"),
              fileInput("train_group_file", "", accept = c(".csv"))
            ),
            div(class = "file-input-container",
              actionButton("browse_valid_data", "浏览验证数据文件", class = "file-input-button"),
              fileInput("valid_data_file", "", accept = c(".csv"))
            ),
            div(class = "file-input-container",
              actionButton("browse_valid_group", "浏览验证分组文件", class = "file-input-button"),
              fileInput("valid_group_file", "", accept = c(".csv"))
            ),

            h4(txt$output_settings),
            div(class = "file-input-container",
              actionButton("browse_output_dir", "选择输出目录", class = "file-input-button"),
              div(style = "margin-top: 10px;",
                textInput("output_dir_path", "输出目录路径:", value = getwd()),
                actionButton("select_output_dir", "浏览...")
              )
            ),

            h4(txt$pdf_settings),
            numericInput("pdf_width", txt$pdf_width, value = 8, min = 1),
            numericInput("pdf_height", txt$pdf_height, value = 6, min = 1),
            
            # 颜色选择器
            div(class = "color-picker-container",
              span(class = "color-picker-label", "箱线图颜色:"),
              colourInput("boxplot_color", "", value = "steelblue")
            ),
            div(class = "color-picker-container",
              span(class = "color-picker-label", "火山图点颜色:"),
              colourInput("volcano_point_color", "", value = "blue")
            ),
            div(class = "color-picker-container",
              span(class = "color-picker-label", "UMAP图点颜色:"),
              colourInput("umap_point_color", "", value = "blue")
            ),
            div(class = "color-picker-container",
              span(class = "color-picker-label", "均值方差点颜色:"),
              colourInput("mean_var_point_color", "", value = "blue")
            ),

            actionButton("run_processing", txt$run_button, class = "btn-primary"),
            
            # 预览按钮
            div(style = "margin-top: 20px",
              h4("图表预览和设置"),
              actionButton("preview_statistical", "统计图预览设置", class = "btn-info"),
              actionButton("preview_umap", "UMAP图预览设置", class = "btn-info"),
              actionButton("preview_mean_variance", "均值方差图预览设置", class = "btn-info"),
              actionButton("preview_all_plots", "所有图表预览设置", class = "btn-info")
            )
          ),
          mainPanel(
            div(class = "main-panel",
              h3(txt$processing_output),
              verbatimTextOutput("console_output"),
              
              # 预览图容器
              div(class = "preview-container",
                h4("当前预览图"),
                plotOutput("current_preview", height = "400px")
              ),
              
              # 下载按钮
              div(style = "margin-top: 20px",
                downloadButton("download_train_common", "下载训练集共同基因数据 (.csv)", class = "download-button"),
                downloadButton("download_valid_common", "下载验证集共同基因数据 (.csv)", class = "download-button"),
                downloadButton("download_train_statistical_plots", "下载训练集统计图 (.pdf)", class = "download-button"),
                downloadButton("download_valid_statistical_plots", "下载验证集统计图 (.pdf)", class = "download-button"),
                downloadButton("download_train_umap_plot", "下载训练集UMAP图 (.pdf)", class = "download-button"),
                downloadButton("download_valid_umap_plot", "下载验证集UMAP图 (.pdf)", class = "download-button"),
                downloadButton("download_train_mean_variance", "下载训练集均值方差趋势 (.pdf)", class = "download-button"),
                downloadButton("download_valid_mean_variance", "下载验证集均值方差趋势 (.pdf)", class = "download-button"),
                downloadButton("download_train_all_plots", "下载训练集无异常值图 (.pdf)", class = "download-button"),
                downloadButton("download_valid_all_plots", "下载验证集无异常值图 (.pdf)", class = "download-button")
              )
            )
          )
        )
      ),
      tabPanel(txt$tab2,
        sidebarLayout(
          sidebarPanel(
            h4(txt$input_files),
            textInput("lasso_train_data_path", txt$train_data, value = "data/processed/train_processed.csv"),
            textInput("lasso_valid_data_path", txt$valid_data, value = "data/processed/valid_processed.csv"),
            textInput("lasso_train_group_path", txt$train_data, value = "data/processed/train_groups.csv"),
            textInput("lasso_valid_group_path", txt$valid_data, value = "data/processed/valid_groups.csv"),

            h4(txt$output_settings),
            textInput("lasso_output_folder", txt$output_dir, value = "output/results"),

            h4(txt$pdf_settings),
            numericInput("lasso_pdf_width", txt$pdf_width, value = 10, min = 1),
            numericInput("lasso_pdf_height", txt$pdf_height, value = 6, min = 1),
            textInput("lasso_plot_title", "主图标题:", value = "LASSO回归系数 (固定 λ 值)"),
            textInput("lasso_path_plot_title", "LASSO路径图标题:", value = "LASSO回归路径图 (固定 λ 值)"),
            textInput("lasso_coefficients_plot_title", "系数图标题:", value = "LASSO回归系数 (固定 λ 值)"),
            textInput("lasso_pdf_color", "柱状图颜色:", value = "steelblue"),

            h4(txt$lasso_settings),
            numericInput("fixed_lambda", txt$fixed_lambda, value = 0.1),

            actionButton("run_lasso_analysis", txt$run_analysis,
                         class = "btn-primary", style = "margin-top: 10px;")
          ),
          mainPanel(
            h3(txt$analysis_output),
            verbatimTextOutput("lasso_console_output"),
            downloadButton("download_lasso_results", if (current_lang == "cn") "下载预测结果 (.xlsx)" else "Download Prediction Results (.xlsx)"),
            downloadButton("download_lasso_coefficients", if (current_lang == "cn") "下载模型系数 (.xlsx)" else "Download Model Coefficients (.xlsx)"),
            downloadButton("download_lasso_selected_genes", if (current_lang == "cn") "下载筛选基因 (.xlsx)" else "Download Selected Genes (.xlsx)"),
            downloadButton("download_lasso_cv_curve_pdf", "下载CV曲线 (.pdf)"),
            downloadButton("download_lasso_path_pdf", "下载LASSO路径图 (.pdf)"),
            downloadButton("download_lasso_coefficients_pdf", "下载系数图 (.pdf)"),
            uiOutput("download_buttons_step2")
          )
        )
      )
    )
  })

  # 预览图渲染
  output$current_preview <- renderPlot({
    req(input$preview_type)
    # 根据预览类型生成相应的图
    # ... 预览图生成代码 ...
  })

  # 文件选择器处理
  observeEvent(input$browse_train_data, {
    shinyjs::click("train_data_file")
  })
  
  observeEvent(input$browse_train_group, {
    shinyjs::click("train_group_file")
  })
  
  observeEvent(input$browse_valid_data, {
    shinyjs::click("valid_data_file")
  })
  
  observeEvent(input$browse_valid_group, {
    shinyjs::click("valid_group_file")
  })
  
  observeEvent(input$select_output_dir, {
    shinyDirChoose(input, "output_dir", roots = volumes, session = session)
  })
  
  observeEvent(input$output_dir, {
    if (!is.null(input$output_dir)) {
      path <- parseDirPath(volumes, input$output_dir)
      updateTextInput(session, "output_dir_path", value = path)
    }
  })
}

# 正确结尾：返回 shinyApp 对象
shinyApp(ui = ui, server = server, options = list(port = 3837))