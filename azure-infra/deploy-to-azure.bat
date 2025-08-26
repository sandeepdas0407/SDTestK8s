@echo off
echo 🚀 Deploying Blog Application to Azure AKS...

REM Configuration
set RESOURCE_GROUP=rg-blog-app
set ACR_NAME=
set AKS_NAME=aks-blog-app
set IMAGE_TAG=latest

REM Check if Azure CLI is logged in
az account show >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Please login to Azure CLI first: az login
    exit /b 1
)

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ kubectl is not installed. Please install kubectl.
    exit /b 1
)

echo 🔍 Getting ACR name...
for /f "tokens=*" %%i in ('az acr list --resource-group %RESOURCE_GROUP% --query "[0].name" -o tsv') do set ACR_NAME=%%i

if "%ACR_NAME%"=="" (
    echo ❌ Could not find ACR in resource group %RESOURCE_GROUP%
    exit /b 1
)
echo ✅ Found ACR: %ACR_NAME%

echo 🔨 Building and pushing Docker image...

REM Get ACR login server
for /f "tokens=*" %%i in ('az acr show --name %ACR_NAME% --resource-group %RESOURCE_GROUP% --query "loginServer" -o tsv') do set ACR_LOGIN_SERVER=%%i

REM Login to ACR
az acr login --name %ACR_NAME%

REM Build and tag image
cd ..
echo 📦 Publishing application...
cd WebApplication1
dotnet publish -c Release -o ../publish --self-contained -r linux-x64
cd ..

echo 🐳 Building Docker image...
docker build -t blog-app:%IMAGE_TAG% .

REM Tag for ACR
docker tag blog-app:%IMAGE_TAG% %ACR_LOGIN_SERVER%/blog-app:%IMAGE_TAG%

REM Push to ACR
echo 📤 Pushing image to ACR...
docker push %ACR_LOGIN_SERVER%/blog-app:%IMAGE_TAG%

echo ✅ Image pushed successfully: %ACR_LOGIN_SERVER%/blog-app:%IMAGE_TAG%

cd azure-infra

echo 🔑 Getting AKS credentials...
az aks get-credentials --resource-group %RESOURCE_GROUP% --name %AKS_NAME% --overwrite-existing
echo ✅ AKS credentials configured

echo 📝 Updating Kubernetes manifests...
REM Create temporary PowerShell script to update manifests
echo $acrServer = "%ACR_LOGIN_SERVER%" > update-manifests.ps1
echo $imageTag = "%IMAGE_TAG%" >> update-manifests.ps1
echo (Get-Content "../k8s/deployment.yaml") -replace "image: blog-app:latest", "image: $acrServer/blog-app:$imageTag" -replace "imagePullPolicy: IfNotPresent", "imagePullPolicy: Always" ^| Set-Content "../k8s/deployment.yaml" >> update-manifests.ps1
echo (Get-Content "../k8s/k8s-all-in-one.yaml") -replace "image: blog-app:latest", "image: $acrServer/blog-app:$imageTag" ^| Set-Content "../k8s/k8s-all-in-one.yaml" >> update-manifests.ps1

powershell -ExecutionPolicy Bypass -File update-manifests.ps1
del update-manifests.ps1
echo ✅ Kubernetes manifests updated

echo 🚀 Deploying to AKS...
kubectl apply -f ../k8s/k8s-all-in-one.yaml

echo ⏳ Waiting for deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/blog-app-deployment -n blog-app

if %ERRORLEVEL% EQU 0 (
    echo 🎉 Deployment successful!
    echo.
    echo 📊 Deployment Status:
    kubectl get pods -n blog-app -o wide
    echo.
    echo 🌐 Service Information:
    kubectl get services -n blog-app
    echo.
    echo 📋 Useful commands:
    echo   kubectl get all -n blog-app
    echo   kubectl logs -f deployment/blog-app-deployment -n blog-app
    echo   kubectl get service blog-app-nodeport -n blog-app
) else (
    echo ❌ Deployment failed
    kubectl get pods -n blog-app
    exit /b 1
)

echo ✅ Azure AKS deployment completed!
