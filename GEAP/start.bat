@echo off
echo 基因表达数据分析平台启动器
echo Gene Expression Analysis Platform Launcher
echo ----------------------------------------

REM 检查 Docker 是否安装
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Docker未安装
    echo Error: Docker is not installed
    echo.
    echo 请访问以下链接安装Docker:
    echo Please visit the following link to install Docker:
    echo https://docs.docker.com/get-docker/
    pause
    exit /b 1
)

REM 检查 Docker Compose 是否安装
where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    echo 错误: Docker Compose未安装
    echo Error: Docker Compose is not installed
    echo.
    echo 请访问以下链接安装Docker Compose:
    echo Please visit the following link to install Docker Compose:
    echo https://docs.docker.com/compose/install/
    pause
    exit /b 1
)

REM 创建必要的目录
echo 创建必要的目录...
echo Creating necessary directories...
mkdir data\raw data\processed output\plots output\results www 2>nul

REM 启动应用
echo 启动应用...
echo Starting application...
docker-compose up --build -d

REM 等待应用启动
echo 等待应用启动...
echo Waiting for application to start...
timeout /t 5 /nobreak >nul

REM 检查应用是否成功启动
docker-compose ps | find "Up" >nul
if %errorlevel% equ 0 (
    echo 应用已成功启动!
    echo Application started successfully!
    echo.
    echo 请在浏览器中访问: http://localhost:3838
    echo Please visit: http://localhost:3838
) else (
    echo 应用启动失败，请检查Docker日志:
    echo Application failed to start, please check Docker logs:
    docker-compose logs
)

pause 