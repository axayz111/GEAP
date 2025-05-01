# =====================================================
# 包管理模块
# 作者：[您的名字]
# 最后更新：2024-05-01
# 描述：此文件负责包的加载和管理，避免重复加载和循环依赖
# =====================================================

# 定义包依赖关系
package_dependencies <- list(
  # 基础包
  base = c("shiny", "conflicted"),
  
  # 数据处理包
  data_processing = c("dplyr", "tidyr", "readr", "tibble"),
  
  # 可视化包
  visualization = c("ggplot2", "ggpubr", "scales", "Cairo"),
  
  # 分析包
  analysis = c("limma", "factoextra", "umap", "glmnet"),
  
  # 其他功能包
  utilities = c("shinyjs", "colourpicker", "VennDiagram", "spatstat.geom", "readxl", "openxlsx")
)

# 检查包是否已加载
is_package_loaded <- function(package_name) {
  return(package_name %in% (.packages()))
}

# 安全加载单个包
safe_load_package <- function(package_name) {
  if (!is_package_loaded(package_name)) {
    tryCatch({
      # 使用 require 而不是 library，因为它会返回加载状态
      loaded <- require(package_name, character.only = TRUE, quietly = TRUE)
      if (!loaded) {
        message("尝试安装包: ", package_name)
        install.packages(package_name, dependencies = TRUE, quiet = TRUE)
        loaded <- require(package_name, character.only = TRUE, quietly = TRUE)
      }
      return(loaded)
    }, error = function(e) {
      message("加载包 ", package_name, " 时出错: ", e$message)
      return(FALSE)
    })
  }
  return(TRUE)
}

# 按依赖关系加载包组
load_package_group <- function(group_name) {
  message("正在加载包组: ", group_name)
  packages <- package_dependencies[[group_name]]
  for (package in packages) {
    message("尝试加载包: ", package)
    if (!safe_load_package(package)) {
      stop("加载包组 ", group_name, " 失败")
    }
  }
}

# 设置函数优先级
set_function_preferences <- function() {
  suppressMessages({
    conflict_prefer("filter", "dplyr")
    conflict_prefer("lag", "dplyr")
    conflict_prefer("col_factor", "readr")
    conflict_prefer("discard", "scales")
    conflict_prefer("show", "shinyjs")
    conflict_prefer("expand", "tidyr")
    conflict_prefer("pack", "tidyr")
    conflict_prefer("unpack", "tidyr")
    conflict_prefer("rotate", "VennDiagram")
    conflict_prefer("border", "spatstat.geom")
  })
}

# 主加载函数
load_all_packages <- function() {
  message("开始加载所有包...")
  
  # 按依赖顺序加载包组
  load_package_group("base")
  load_package_group("data_processing")
  load_package_group("visualization")
  load_package_group("analysis")
  load_package_group("utilities")
  
  # 设置函数优先级
  set_function_preferences()
  
  message("所有包加载完成")
}

# 导出加载函数
export_load_packages <- function() {
  if (!exists("packages_loaded")) {
    load_all_packages()
    packages_loaded <- TRUE
  }
} 