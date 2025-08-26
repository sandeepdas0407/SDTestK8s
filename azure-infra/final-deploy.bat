@echo off
echo ========================================
echo    Final AKS Deployment Script
echo ========================================
echo.

echo [1/6] Checking AKS cluster status...
az aks show --resource-group "rg-blog-app" --name "aks-blog-app" --query "provisioningState" -o tsv
if %ERRORLEVEL% neq 0 (
    echo ERROR: AKS cluster not ready or doesn't exist
    echo Please wait for cluster creation to complete
    pause
    exit /b 1
)

echo [2/6] Getting AKS credentials...
az aks get-credentials --resource-group "rg-blog-app" --name "aks-blog-app" --overwrite-existing
if %ERRORLEVEL% neq 0 (
    echo ERROR: Failed to get AKS credentials
    pause
    exit /b 1
)

echo [3/6] Checking ACR repositories...
az acr repository list --name "acrblogappsdk8s" --output table
if %ERRORLEVEL% neq 0 (
    echo ERROR: Cannot access ACR or no images found
    echo You may need to build the image first:
    echo   az acr build --registry acrblogappsdk8s --image blog-app:v1 .
    pause
    exit /b 1
)

echo [4/6] Updating Kubernetes manifests with ACR image...
cd ..\k8s
copy k8s-all-in-one.yaml k8s-all-in-one-backup.yaml > nul
powershell -Command "(Get-Content k8s-all-in-one.yaml) -replace 'image: blog-app:latest', 'image: acrblogappsdk8s.azurecr.io/blog-app:v1' | Set-Content k8s-all-in-one.yaml"
echo Updated image reference to: acrblogappsdk8s.azurecr.io/blog-app:v1

echo [5/6] Deploying to AKS...
kubectl apply -f k8s-all-in-one.yaml
if %ERRORLEVEL% neq 0 (
    echo ERROR: Deployment failed
    pause
    exit /b 1
)

echo [6/6] Waiting for deployment to be ready...
kubectl wait --for=condition=available --timeout=300s deployment/blog-app-deployment -n blog-app

echo.
echo ========================================
echo    Deployment Status
echo ========================================
kubectl get all -n blog-app

echo.
echo ========================================
echo    Access Your Application
echo ========================================
echo.
echo Option 1 - Port Forward (immediate access):
echo   kubectl port-forward service/blog-app-service 8080:80 -n blog-app
echo   Then open: http://localhost:8080
echo.
echo Option 2 - External Load Balancer (if available):
kubectl get service blog-app-nodeport -n blog-app -o jsonpath="{.status.loadBalancer.ingress[0].ip}"
if %ERRORLEVEL% equ 0 (
    echo   External IP found above - access directly via that IP
) else (
    echo   No external IP assigned - use port forwarding
)

echo.
echo ========================================
echo    Useful Commands
echo ========================================
echo View logs:     kubectl logs -f deployment/blog-app-deployment -n blog-app
echo Scale up:      kubectl scale deployment blog-app-deployment --replicas=5 -n blog-app
echo View pods:     kubectl get pods -n blog-app -o wide
echo Describe pod:  kubectl describe pod [POD-NAME] -n blog-app
echo.
echo Deployment complete!
pause
