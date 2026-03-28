# PowerShell 构建脚本快捷函数
# 将此文件内容添加到你的 PowerShell 配置文件中

# 方法：运行以下命令查看配置文件路径
# echo $PROFILE

# 然后将下面的函数添加到该文件中

# 切换到 example_use 目录并执行构建脚本的函数
function Invoke-ExampleBuild {
    param(
        [string]$Command = "help"
    )
    
    $scriptPath = "C:\Users\admin\Desktop\lite_simple_ui\example_use\build.ps1"
    
    if (Test-Path $scriptPath) {
        & $scriptPath $Command
    } else {
        Write-Host "错误：找不到 build.ps1 脚本" -ForegroundColor Red
    }
}

# 设置别名，这样可以直接使用 make 命令
Set-Alias -Name make -Value Invoke-ExampleBuild -Force

# 使用示例:
# make dev
# make apk
# make windows
# make clean
