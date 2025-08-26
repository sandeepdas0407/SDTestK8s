@echo off
echo 🚀 Deploying Blog Application to Kubernetes...

REM Check if kubectl is available
kubectl version --client >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ kubectl is not installed or not in PATH
    echo Please install kubectl: https://kubernetes.io/docs/tasks/tools/
    exit /b 1
)

REM Check if cluster is accessible
kubectl cluster-info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Cannot connect to Kubernetes cluster
    echo Please ensure your cluster is running and kubectl is configured
    exit /b 1
)

echo ✅ Kubernetes cluster is accessible

REM Build Docker image first
echo 📦 Building Docker image...
cd ..
call build-docker.bat

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Failed to build Docker image
    exit /b 1
)

REM Load image into cluster (for local development)
echo 📥 Loading image into cluster...
REM For Docker Desktop Kubernetes
docker image ls blog-app:latest >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo ✅ Image available for Kubernetes
)

cd k8s

echo 🔧 Applying Kubernetes manifests...

REM Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

REM Optional: Apply HPA if metrics server is available
kubectl get apiservice v1beta1.metrics.k8s.io >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    kubectl apply -f hpa.yaml
    echo ✅ HPA applied
) else (
    echo ⚠️  Metrics server not found, skipping HPA
)

REM Optional: Apply Ingress if ingress controller is available
kubectl get ingressclass >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    kubectl apply -f ingress.yaml
    echo ✅ Ingress applied
) else (
    echo ⚠️  No ingress controller found, skipping Ingress
)

echo ⏳ Waiting for deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/blog-app-deployment -n blog-app

if %ERRORLEVEL% EQU 0 (
    echo 🎉 Deployment successful!
    echo.
    echo 📊 Deployment Status:
    kubectl get pods -n blog-app
    echo.
    echo 🌐 Access your application:
    echo    NodePort: http://localhost:30080
    echo    Port Forward: kubectl port-forward service/blog-app-service 8080:80 -n blog-app
    echo.
    echo 📋 Useful commands:
    echo    kubectl get all -n blog-app
    echo    kubectl logs -f deployment/blog-app-deployment -n blog-app
    echo    kubectl delete namespace blog-app
) else (
    echo ❌ Deployment failed or timed out
    kubectl get pods -n blog-app
    exit /b 1
)
