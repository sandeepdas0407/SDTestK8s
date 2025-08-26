@echo off
echo 🧹 Cleaning up Blog Application from Kubernetes...

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ kubectl is not installed or not in PATH
    exit /b 1
)

echo 🗑️  Deleting namespace and all resources...
kubectl delete namespace blog-app

if %ERRORLEVEL% EQU 0 (
    echo ✅ Cleanup completed successfully!
    echo All blog-app resources have been removed from the cluster.
) else (
    echo ❌ Cleanup failed or namespace doesn't exist
    exit /b 1
)
