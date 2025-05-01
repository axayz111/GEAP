# =====================================================
# 数据预处理服务器模块
# 作者：[您的名字]
# 最后更新：2024-05-01
# 描述：此文件负责数据预处理阶段的所有服务器端逻辑
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
# 基因映射和ID移除函数
map_gene_and_remove_id <- function(data, id_to_gene) {
  data %>% 
    left_join(id_to_gene, by = "id") %>% 
    select(gene, everything(), -id) %>% 
    filter(!is.na(gene) & gene != "" & !grepl("^\\s*$", gene)) %>% 
    distinct(gene, .keep_all = TRUE)
}

# 数据预处理函数
preprocess_data <- function(data, file_name) {
  # 处理缺失值
  data <- data %>% 
    mutate(across(where(is.numeric), ~ ifelse(is.na(.), mean(., na.rm = TRUE), .)))
  
  # 对非对数化数据进行处理
  if (!grepl("log", file_name)) {
    data_numeric <- data %>% select_if(is.numeric)
    data_numeric <- log1p(data_numeric)  # log1p变换
    data_numeric <- scale(data_numeric)  # 标准化
    data <- bind_cols(data %>% select(gene), data_numeric)
  }
  return(data)
}

# 异常值移除函数
remove_outliers <- function(data) {
  data %>% mutate(across(where(is.numeric), ~ {
    Q1 <- quantile(., 0.25, na.rm = TRUE)
    Q3 <- quantile(., 0.75, na.rm = TRUE)
    IQR <- Q3 - Q1
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    ifelse(. < lower_bound | . > upper_bound, NA, .)
  }))
}

# ==== 第四部分：可视化函数定义 ====
# 数据可视化函数
visualize_data_shiny <- function(data_scaled, group_info, prefix, output_dir, pdf_width, pdf_height, title_prefix) {
  # 差异表达分析
  design <- model.matrix(~ factor(group_info$Group))
  fit <- eBayes(lmFit(data_scaled %>% select(-gene), design))
  tT2 <- topTable(fit, coef = 2, adjust.method = "BH", number = Inf)
  dT <- decideTests(fit, adjust.method = "BH", p.value = 0.05)
  
  # 提取表达矩阵和分组信息
  ex <- data_scaled %>% select(-gene)
  gs <- factor(group_info$Group)
  
  # 生成统计图
  pdf(file.path(output_dir, paste0(prefix, "_statistical_plots.pdf")), width = pdf_width, height = pdf_height)
  hist(tT2$adj.P.Val, col = "grey", border = "white", xlab = "P-adj", ylab = "Number of genes", main = paste(title_prefix, "P-adj value distribution"))
  vennDiagram(dT, circle.col = palette())
  qqt(fit$t[!is.na(fit$F)], fit$df.total[!is.na(fit$F)], main = paste(title_prefix, "Moderated t statistic"))
  volcanoplot(fit, coef = 1, main = paste(title_prefix, colnames(fit)[1]), pch = 20, highlight = sum(dT[, 1] != 0), names = rep('+', nrow(fit)))
  plotMD(fit, column = 1, status = dT[, 1], legend = FALSE, pch = 20, cex = 1); abline(h = 0)
  boxplot(ex[, order(gs)], boxwex = 0.6, notch = TRUE, outline = FALSE, las = 2, col = gs[order(gs)])
  legend("topleft", levels(gs), fill = palette(), bty = "n")
  plotDensities(ex, group = gs, main = paste(title_prefix, "Expression Value Distribution"), legend = "topright")
  dev.off()
  
  # 生成UMAP图
  pdf(file.path(output_dir, paste0(prefix, "_umap_plot.pdf")), width = pdf_width, height = pdf_height)
  ump <- umap(t(na.omit(ex[!duplicated(ex), ])), n_neighbors = 15, random_state = 123)
  plot(ump$layout, main = paste(title_prefix, "UMAP plot, nbrs=15"), xlab = "", ylab = "", col = gs, pch = 20, cex = 1.5)
  legend("topright", inset = c(-0.15, 0), legend = levels(gs), pch = 20, col = 1:nlevels(gs), title = "Group", pt.cex = 1.5)
  dev.off()
  
  # 生成均值方差趋势图
  pdf(file.path(output_dir, paste0(prefix, "_mean_variance_trend.pdf")), width = pdf_width, height = pdf_height)
  plotSA(fit, main = paste(title_prefix, "Mean variance trend"))
  dev.off()
}

# ==== 第五部分：服务器逻辑 ====
step1_server <- function(input, output, session) {
  # 控制台输出处理
  output$console_output <- renderPrint({
    input$run_processing

    isolate({
      output_dir <- input$output_dir
      data_dir <- output_dir
      dir.create(data_dir, showWarnings = FALSE, recursive = TRUE)

      train_data_path <- input$train_data_path
      train_group_path <- input$train_group_path
      train_id_to_gene_path <- input$train_id_to_gene_path
      valid_data_path <- input$valid_data_path
      valid_group_path <- input$valid_group_path
      valid_id_to_gene_path <- input$valid_id_to_gene_path

      pdf_width <- input$pdf_width
      pdf_height <- input$pdf_height
      statistical_plots_title <- input$statistical_plots_title
      umap_plot_title <- input$umap_plot_title
      mean_variance_title <- input$mean_variance_title
      all_plots_no_outliers_title <- input$all_plots_no_outliers_title
      boxplot_color <- input$boxplot_color
      volcano_point_color <- input$volcano_point_color
      umap_point_color <- input$umap_point_color
      mean_var_point_color <- input$mean_var_point_color

      # 读取数据
      train_data <- read_csv(train_data_path)
      train_group <- read_csv(train_group_path)
      train_id_to_gene <- read_csv(train_id_to_gene_path)
      valid_data <- read_csv(valid_data_path)
      valid_group <- read_csv(valid_group_path)
      valid_id_to_gene <- read_csv(valid_id_to_gene_path)

      # 基因映射和ID移除
      train_data <- map_gene_and_remove_id(train_data, train_id_to_gene)
      valid_data <- map_gene_and_remove_id(valid_data, valid_id_to_gene)

      # 处理 "null" 值并转换为数值
      train_data <- train_data %>% mutate(across(everything(), ~ ifelse(. == "null", NA, .))) %>% mutate(across(-gene, as.numeric))
      valid_data <- valid_data %>% mutate(across(everything(), ~ ifelse(. == "null", NA, .))) %>% mutate(across(-gene, as.numeric))

      # 数据预处理函数
      train_scaled <- preprocess_data(train_data, "train_data.csv")
      valid_scaled <- preprocess_data(valid_data, "valid_data.csv")

      # 查找共同基因
      common_genes <- intersect(train_scaled$gene, valid_scaled$gene)
      train_common <- train_scaled %>% filter(gene %in% common_genes) %>% arrange(gene)
      valid_common <- valid_scaled %>% filter(gene %in% common_genes) %>% arrange(gene)

      # 保存共同基因数据
      if (nrow(train_common) > 0) write_csv(train_common, file.path(data_dir, "train_common_scaled.csv"))
      if (nrow(valid_common) > 0) write_csv(valid_common, file.path(data_dir, "valid_common_scaled.csv"))

      # 可视化函数
      visualize_data_shiny(train_scaled, train_group, "train", output_dir, pdf_width, pdf_height, statistical_plots_title)
      visualize_data_shiny(valid_scaled, valid_group, "valid", output_dir, pdf_width, pdf_height, statistical_plots_title)

      # 生成无异常值图
      train_scaled_no_outliers <- remove_outliers(train_scaled)
      valid_scaled_no_outliers <- remove_outliers(valid_scaled)

      generate_plots_shiny(train_scaled_no_outliers, train_group, "train", output_dir, pdf_width, pdf_height, all_plots_no_outliers_title, boxplot_color, volcano_point_color, umap_point_color, mean_var_point_color)
      generate_plots_shiny(valid_scaled_no_outliers, valid_group, "valid", output_dir, pdf_width, pdf_height, all_plots_no_outliers_title, boxplot_color, volcano_point_color, umap_point_color, mean_var_point_color)

      cat("数据处理和可视化完成，结果已保存到目录：", output_dir, "\n")
    })
  })

  # 预览图渲染
  output$statistical_preview <- renderPlot({
    req(input$statistical_color)
    
    # 创建统计图预览
    design <- model.matrix(~ factor(train_group$Group))
    fit <- eBayes(lmFit(train_scaled %>% select(-gene), design))
    tT2 <- topTable(fit, coef = 2, adjust.method = "BH", number = Inf)
    
    par(mfrow = c(2, 2))
    # P值分布直方图
    hist(tT2$adj.P.Val, col = input$statistical_color, border = "white",
         xlab = "P-adj", ylab = "基因数量",
         main = "P值分布")
    
    # 火山图
    volcanoplot(fit, coef = 1, main = "火山图",
               pch = 20, highlight = 10,
               names = rep('+', nrow(fit)))
    
    # MA图
    plotMD(fit, column = 1, status = rep(1, nrow(fit)),
           legend = FALSE, pch = 20, cex = 1,
           main = "MA图")
    abline(h = 0)
    
    # 密度图
    plotDensities(train_scaled %>% select(-gene),
                 group = factor(train_group$Group),
                 main = "表达值分布",
                 legend = "topright")
  })

  output$umap_preview <- renderPlot({
    req(input$umap_color)
    
    # 创建UMAP预览
    ex <- train_scaled %>% select(-gene)
    gs <- factor(train_group$Group)
    ump <- umap(t(na.omit(ex[!duplicated(ex), ])), n_neighbors = 15, random_state = 123)
    
    plot(ump$layout, main = "UMAP图",
         xlab = "UMAP1", ylab = "UMAP2",
         col = input$umap_color, pch = 20, cex = 1.5)
    legend("topright", legend = levels(gs),
           pch = 20, col = input$umap_color,
           title = "分组")
  })

  output$mean_variance_preview <- renderPlot({
    req(input$mean_variance_color)
    
    # 创建均值方差趋势图预览
    ex <- train_scaled %>% select(-gene)
    mean_values <- rowMeans(ex)
    variance_values <- apply(ex, 1, var, na.rm = TRUE)
    mean_var_data <- data.frame(mean = mean_values, variance = variance_values)
    
    ggplot(mean_var_data, aes(x = mean, y = variance)) +
      geom_point(color = input$mean_variance_color, alpha = 0.5) +
      theme_minimal() +
      labs(title = "均值方差趋势图",
           x = "平均表达量",
           y = "方差") +
      theme(plot.title = element_text(hjust = 0.5))
  })

  output$all_plots_preview <- renderPlot({
    req(input$all_plots_color)
    
    # 创建所有图表的预览
    ex <- train_scaled %>% select(-gene)
    gs <- factor(train_group$Group)
    
    par(mfrow = c(2, 2))
    
    # 箱线图
    boxplot(ex[, order(gs)], boxwex = 0.6,
            notch = TRUE, outline = FALSE,
            las = 2, col = input$all_plots_color,
            main = "箱线图")
    
    # Q-Q图
    qqnorm(unlist(ex),
           main = "Q-Q图")
    qqline(unlist(ex), col = input$all_plots_color)
    
    # 密度图
    plot(density(unlist(ex), na.rm = TRUE),
         main = "密度图",
         col = input$all_plots_color)
    
    # 均值-方差图
    mean_values <- rowMeans(ex)
    variance_values <- apply(ex, 1, var, na.rm = TRUE)
    plot(mean_values, variance_values,
         main = "均值-方差图",
         xlab = "平均值", ylab = "方差",
         col = input$all_plots_color,
         pch = 20)
  })

  # 更新应用设置的观察者
  observeEvent(input$statistical_apply, {
    updateColourInput(session, "boxplot_color", value = input$statistical_color)
    removeModal()
  })

  observeEvent(input$umap_apply, {
    updateColourInput(session, "umap_point_color", value = input$umap_color)
    removeModal()
  })

  observeEvent(input$mean_variance_apply, {
    updateColourInput(session, "mean_var_point_color", value = input$mean_variance_color)
    removeModal()
  })

  observeEvent(input$all_plots_apply, {
    updateColourInput(session, "boxplot_color", value = input$all_plots_color)
    updateColourInput(session, "volcano_point_color", value = input$all_plots_color)
    updateColourInput(session, "umap_point_color", value = input$all_plots_color)
    updateColourInput(session, "mean_var_point_color", value = input$all_plots_color)
    removeModal()
  })

  # 预览按钮事件处理
  observeEvent(input$preview_statistical, {
    showModal(showPlotPreview("statistical", train_scaled))
  })

  observeEvent(input$preview_umap, {
    showModal(showPlotPreview("umap", train_scaled))
  })

  observeEvent(input$preview_mean_variance, {
    showModal(showPlotPreview("mean_variance", train_scaled))
  })

  observeEvent(input$preview_all_plots, {
    showModal(showPlotPreview("all_plots", train_scaled))
  })

  # 下载处理
  output$download_train_common <- downloadHandler(
    filename = function() {
      "train_common_genes.csv"
    },
    content = function(file) {
      # TODO: 添加下载逻辑
    }
  )
}

# ==== 第六部分：预览对话框函数 ====
# 图表预览模态对话框函数
showPlotPreview <- function(plot_type, data = NULL) {
  modalDialog(
    title = "图表预览和设置",
    size = "l",
    
    # 颜色选择器
    div(class = "color-picker-container",
      span(class = "color-picker-label", "主要颜色:"),
      colourInput(paste0(plot_type, "_color"), "", value = switch(plot_type,
        "statistical" = "#1f77b4",
        "umap" = "#2ca02c",
        "mean_variance" = "#ff7f0e",
        "all_plots" = "#d62728"
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
  step1_server = step1_server,
  map_gene_and_remove_id = map_gene_and_remove_id,
  preprocess_data = preprocess_data,
  remove_outliers = remove_outliers,
  visualize_data_shiny = visualize_data_shiny
)