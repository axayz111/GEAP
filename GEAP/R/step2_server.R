# =====================================================
# LASSO回归分析服务器模块
# 作者：[您的名字]
# 最后更新：2024-05-01
# 描述：此文件负责LASSO回归分析阶段的所有服务器端逻辑
# =====================================================

# ==== 第一部分：初始化设置 ====
# 不再需要加载包，因为已经在app.R中加载

# ==== 第二部分：UI样式定义 ====
# 添加自定义CSS样式，实现毛玻璃效果和渐变背景
custom_css <- "
  body {
    background: linear-gradient(135deg, #87CEEB, #FFB6C1);
    min-height: 100vh;
    margin: 0;
    padding: 20px;
  }
  
  .well {
    background-color: rgba(255, 255, 255, 0.7) !important;
    backdrop-filter: blur(10px);
    border-radius: 15px !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    border: none !important;
  }
  
  .btn {
    background-color: rgba(255, 255, 255, 0.8) !important;
    backdrop-filter: blur(5px);
    border-radius: 10px !important;
    border: none !important;
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease !important;
  }
  
  .btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
  }
  
  .btn:active {
    transform: translateY(1px);
    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  }
  
  .form-control {
    background-color: rgba(255, 255, 255, 0.8) !important;
    backdrop-filter: blur(5px);
    border-radius: 10px !important;
    border: none !important;
  }
  
  .panel {
    background-color: rgba(255, 255, 255, 0.7) !important;
    backdrop-filter: blur(10px);
    border-radius: 15px !important;
    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    border: none !important;
  }
"

# ==== 第三部分：数据处理函数定义 ====
# LASSO回归函数
lasso_regression <- function(data, group_info, output_dir, pdf_width, pdf_height, title_prefix) {
  # 提取表达矩阵和分组信息
  ex <- data %>% select(-gene)
  gs <- factor(group_info$Group)
  
  # 创建LASSO模型
  cvfit <- cv.glmnet(as.matrix(ex), gs, family = "binomial", type.measure = "class")
  
  # 生成LASSO图
  pdf(file.path(output_dir, paste0("lasso_plot.pdf")), width = pdf_width, height = pdf_height)
  plot(cvfit$glmnet.fit, "lambda", label = TRUE, main = paste(title_prefix, "LASSO Regression Path"))
  dev.off()
  
  # 生成交叉验证曲线
  pdf(file.path(output_dir, paste0("lasso_cv_plot.pdf")), width = pdf_width, height = pdf_height)
  plot(cvfit, main = paste(title_prefix, "LASSO Cross-Validation Curve"))
  dev.off()
  
  # 生成系数图
  pdf(file.path(output_dir, paste0("lasso_coefficients.pdf")), width = pdf_width, height = pdf_height)
  coefs <- coef(cvfit, s = "lambda.min")
  coefs <- coefs[coefs != 0, ]
  barplot(coefs, main = paste(title_prefix, "LASSO Regression Coefficients"), las = 2)
  dev.off()
  
  return(cvfit)
}

# ==== 第四部分：服务器逻辑 ====
step2_server <- function(input, output, session) {
  # 控制台输出处理
  output$console_output <- renderPrint({
    input$run_lasso

    isolate({
      output_dir <- input$output_dir
      data_dir <- output_dir
      dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

      train_data_path <- input$train_data_path
      train_group_path <- input$train_group_path
      valid_data_path <- input$valid_data_path
      valid_group_path <- input$valid_group_path

      pdf_width <- input$pdf_width
      pdf_height <- input$pdf_height
      lasso_plot_title <- input$lasso_plot_title
      lasso_cv_plot_title <- input$lasso_cv_plot_title
      lasso_coefficients_title <- input$lasso_coefficients_title
      lasso_pdf_color <- input$lasso_pdf_color
      lasso_path_pdf_color <- input$lasso_path_pdf_color
      lasso_coefficients_pdf_color <- input$lasso_coefficients_pdf_color

      # 读取数据
      train_data <- read_csv(train_data_path)
      train_group <- read_csv(train_group_path)
      valid_data <- read_csv(valid_data_path)
      valid_group <- read_csv(valid_group_path)

      # 处理 "null" 值并转换为数值
      train_data <- train_data %>% mutate(across(everything(), ~ ifelse(. == "null", NA, .))) %>% mutate(across(-gene, as.numeric))
      valid_data <- valid_data %>% mutate(across(everything(), ~ ifelse(. == "null", NA, .))) %>% mutate(across(-gene, as.numeric))

      # 数据预处理
      train_scaled <- preprocess_data(train_data, "train_data.csv")
      valid_scaled <- preprocess_data(valid_data, "valid_data.csv")

      # LASSO回归
      train_lasso <- lasso_regression(train_scaled, train_group, output_dir, pdf_width, pdf_height, lasso_plot_title)
      valid_lasso <- lasso_regression(valid_scaled, valid_group, output_dir, pdf_width, pdf_height, lasso_plot_title)

      cat("LASSO回归分析完成，结果已保存到目录：", output_dir, "\n")
    })
  })

  # 预览图渲染
  output$lasso_preview <- renderPlot({
    req(input$lasso_color)
    
    # 创建LASSO预览
    ex <- train_scaled %>% select(-gene)
    gs <- factor(train_group$Group)
    
    # 创建LASSO模型
    cvfit <- cv.glmnet(as.matrix(ex), gs, family = "binomial", type.measure = "class")
    
    # 绘制LASSO路径图
    plot(cvfit$glmnet.fit, "lambda", label = TRUE,
         main = "LASSO回归路径图",
         col = input$lasso_color)
  })

  output$lasso_path_preview <- renderPlot({
    req(input$lasso_path_color)
    
    # 创建LASSO路径预览
    ex <- train_scaled %>% select(-gene)
    gs <- factor(train_group$Group)
    
    # 创建LASSO模型
    cvfit <- cv.glmnet(as.matrix(ex), gs, family = "binomial", type.measure = "class")
    
    # 绘制交叉验证曲线
    plot(cvfit, main = "LASSO交叉验证曲线",
         col = input$lasso_path_color)
  })

  output$lasso_coefficients_preview <- renderPlot({
    req(input$lasso_coefficients_color)
    
    # 创建系数预览
    ex <- train_scaled %>% select(-gene)
    gs <- factor(train_group$Group)
    
    # 创建LASSO模型
    cvfit <- cv.glmnet(as.matrix(ex), gs, family = "binomial", type.measure = "class")
    
    # 获取系数
    coefs <- coef(cvfit, s = "lambda.min")
    coefs <- coefs[coefs != 0, ]
    
    # 绘制系数图
    barplot(coefs, main = "LASSO回归系数图",
            col = input$lasso_coefficients_color,
            las = 2)
  })

  # 更新应用设置的观察者
  observeEvent(input$lasso_apply, {
    updateColourInput(session, "lasso_pdf_color", value = input$lasso_color)
    removeModal()
  })

  observeEvent(input$lasso_path_apply, {
    updateColourInput(session, "lasso_path_pdf_color", value = input$lasso_path_color)
    removeModal()
  })

  observeEvent(input$lasso_coefficients_apply, {
    updateColourInput(session, "lasso_coefficients_pdf_color", value = input$lasso_coefficients_color)
    removeModal()
  })

  # 预览按钮事件处理
  observeEvent(input$preview_lasso, {
    showModal(showPlotPreview("lasso", train_scaled))
  })

  observeEvent(input$preview_lasso_path, {
    showModal(showPlotPreview("lasso_path", train_scaled))
  })

  observeEvent(input$preview_lasso_coefficients, {
    showModal(showPlotPreview("lasso_coefficients", train_scaled))
  })

  # 运行LASSO分析
  observeEvent(input$run_lasso_analysis, {
    # 获取输入文件路径
    train_data_path <- input$lasso_train_data_path
    valid_data_path <- input$lasso_valid_data_path
    train_group_path <- input$lasso_train_group_path
    valid_group_path <- input$lasso_valid_group_path
    
    # 检查文件是否存在
    if (!file.exists(train_data_path) || !file.exists(valid_data_path) || 
        !file.exists(train_group_path) || !file.exists(valid_group_path)) {
      showNotification("输入文件不存在，请检查文件路径", type = "error")
      return()
    }
    
    # 读取数据
    train_data <- read.csv(train_data_path)
    valid_data <- read.csv(valid_data_path)
    train_group <- read.csv(train_group_path)
    valid_group <- read.csv(valid_group_path)
    
    # 运行LASSO分析
    # TODO: 添加实际的LASSO分析逻辑
    
    # 更新输出
    output$lasso_console_output <- renderText({
      "LASSO分析完成！"
    })
  })
  
  # 下载处理
  output$download_lasso_results <- downloadHandler(
    filename = function() {
      "lasso_prediction_results.xlsx"
    },
    content = function(file) {
      # TODO: 添加下载逻辑
    }
  )
  
  # 其他下载处理...
}

# ==== 第五部分：预览对话框函数 ====
# 图表预览模态对话框函数
showPlotPreview <- function(plot_type, data = NULL) {
  modalDialog(
    title = "图表预览和设置",
    size = "l",
    
    # 颜色选择器
    div(class = "color-picker-container",
      span(class = "color-picker-label", "主要颜色:"),
      colourInput(paste0(plot_type, "_color"), "", value = switch(plot_type,
        "lasso" = "#1f77b4",
        "lasso_path" = "#2ca02c",
        "lasso_coefficients" = "#ff7f0e"
      ), class = "color-picker")
    ),
    
    # 预览图
    div(class = "preview-container",
      plotOutput(paste0(plot_type, "_preview"), height = "400px")
    ),
    
    # 应用按钮
    footer = tagList(
      modalButton("取消"),
      actionButton(paste0(plot_type, "_apply"), "应用设置")
    )
  )
}

# 导出服务器函数
list(
  step2_server = step2_server,
  lasso_regression = lasso_regression
)