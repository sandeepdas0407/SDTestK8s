@echo off
echo 🧹 Cleaning up Azure AKS resources...

set RESOURCE_GROUP=rg-blog-app

REM Check if Azure CLI is logged in
az account show >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Please login to Azure CLI first: az login
    exit /b 1
)

REM Delete the entire resource group
echo 🗑️  Deleting resource group: %RESOURCE_GROUP%
echo ⚠️  This will delete ALL resources in the resource group!
set /p "confirm=Are you sure? (y/N): "
if /i "%confirm%"=="y" (
    az group delete --name %RESOURCE_GROUP% --yes --no-wait
    echo ✅ Resource group deletion initiated
    echo 🕐 Resources are being deleted in the background
    echo    You can check status with: az group show --name %RESOURCE_GROUP%
) else (
    echo ❌ Cleanup cancelled
)
