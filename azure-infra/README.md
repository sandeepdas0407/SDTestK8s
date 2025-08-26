# Azure AKS Deployment Guide

This guide walks you through deploying the Blog Application to Azure Kubernetes Service (AKS) using Azure Container Registry (ACR).

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Developer     │    │  Azure Container │    │  Azure AKS      │
│   Workstation   │───▶│   Registry      │───▶│   Cluster       │
│                 │    │   (ACR)         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        ▼                       ▼                       ▼
  Docker Build              Store Images            Pull & Deploy
  & Tag Images              blog-app:latest        Kubernetes Pods
```

## 📋 Prerequisites

- ✅ Azure CLI installed and logged in
- ✅ kubectl installed
- ✅ Docker Desktop running
- ✅ .NET 9.0 SDK
- ✅ Azure subscription with necessary permissions

## 🚀 Quick Deployment

### Option 1: Automated Deployment (Recommended)

```cmd
cd azure-infra
deploy-to-azure.bat
```

This script will:
1. Build and publish the .NET application
2. Create Docker image and push to ACR
3. Get AKS credentials
4. Update Kubernetes manifests with ACR image reference
5. Deploy to AKS cluster

### Option 2: Manual Step-by-Step

#### Step 1: Register Azure Providers (One-time setup)
```bash
az provider register --namespace Microsoft.ContainerService
az provider register --namespace Microsoft.ContainerRegistry
```

#### Step 2: Create Azure Resources
```bash
# Create Resource Group
az group create --name "rg-blog-app" --location "East US"

# Create Container Registry
az acr create --resource-group "rg-blog-app" --name "acrblogappsdk8s" --sku Basic --admin-enabled true

# Create AKS Cluster (takes 5-10 minutes)
az aks create --resource-group "rg-blog-app" --name "aks-blog-app" --node-count 2 --node-vm-size "Standard_D2s_v3" --attach-acr "acrblogappsdk8s" --generate-ssh-keys
```

#### Step 3: Build and Push Application
```bash
# Publish .NET application
cd WebApplication1
dotnet publish -c Release -o ../publish --self-contained -r linux-x64
cd ..

# Build and push to ACR (using Azure CLI - bypasses network issues)
az acr build --registry acrblogappsdk8s --image blog-app:latest .
```

#### Step 4: Configure kubectl
```bash
az aks get-credentials --resource-group "rg-blog-app" --name "aks-blog-app" --overwrite-existing
```

#### Step 5: Update Kubernetes Manifests
```bash
# Update image reference in deployment files
# Replace: image: blog-app:latest
# With: image: acrblogappsdk8s.azurecr.io/blog-app:latest
```

#### Step 6: Deploy to AKS
```bash
kubectl apply -f k8s/k8s-all-in-one.yaml
```

## 🌐 Accessing Your Application

### Method 1: LoadBalancer Service (External IP)
```bash
# Check for external IP
kubectl get service blog-app-nodeport -n blog-app

# Access via external IP
http://<EXTERNAL-IP>
```

### Method 2: Port Forwarding
```bash
kubectl port-forward service/blog-app-service 8080:80 -n blog-app
# Access at: http://localhost:8080
```

### Method 3: Azure Load Balancer (Production)
For production, create a LoadBalancer service:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: blog-app-loadbalancer
  namespace: blog-app
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: blog-application
```

## 📊 Monitoring & Management

### View Resources
```bash
# All resources in namespace
kubectl get all -n blog-app

# Pod details
kubectl get pods -n blog-app -o wide

# Check ACR images
az acr repository list --name acrblogappsdk8s
```

### Logs
```bash
# Application logs
kubectl logs -f deployment/blog-app-deployment -n blog-app

# Specific pod logs
kubectl logs <pod-name> -n blog-app
```

### Scaling
```bash
# Manual scaling
kubectl scale deployment blog-app-deployment --replicas=5 -n blog-app

# Auto-scaling (if HPA is enabled)
kubectl get hpa -n blog-app
```

## 🔄 Updates & CI/CD

### Update Application
```bash
# 1. Make code changes
# 2. Build new image with version tag
az acr build --registry acrblogappsdk8s --image blog-app:v2 .

# 3. Update deployment
kubectl set image deployment/blog-app-deployment blog-app=acrblogappsdk8s.azurecr.io/blog-app:v2 -n blog-app

# 4. Check rollout status
kubectl rollout status deployment/blog-app-deployment -n blog-app
```

### Rollback
```bash
kubectl rollout undo deployment/blog-app-deployment -n blog-app
```

## 💰 Cost Management

### Current Resources & Estimated Monthly Cost
- **Resource Group**: rg-blog-app
- **AKS Cluster**: 2 x Standard_D2s_v3 nodes (~$150/month)
- **Container Registry**: Basic tier (~$5/month)
- **Load Balancer**: Standard tier (~$20/month)
- **Storage**: Managed disks (~$10/month)

**Total Estimated**: ~$185/month

### Cost Optimization
```bash
# Scale down for development
kubectl scale deployment blog-app-deployment --replicas=1 -n blog-app

# Stop AKS cluster (deallocates VMs)
az aks stop --resource-group "rg-blog-app" --name "aks-blog-app"

# Start AKS cluster
az aks start --resource-group "rg-blog-app" --name "aks-blog-app"
```

## 🧹 Cleanup

### Remove Application Only
```bash
kubectl delete namespace blog-app
```

### Remove All Azure Resources
```bash
# WARNING: This deletes everything!
az group delete --name "rg-blog-app" --yes --no-wait
```

Or use the cleanup script:
```cmd
cd azure-infra
cleanup-azure.bat
```

## 🚨 Troubleshooting

### Common Issues

1. **Provider Not Registered**
   ```bash
   az provider register --namespace Microsoft.ContainerService
   az provider register --namespace Microsoft.ContainerRegistry
   ```

2. **ACR Push Fails**
   ```bash
   # Use Azure CLI build instead
   az acr build --registry acrblogappsdk8s --image blog-app:latest .
   ```

3. **Pod ImagePullBackOff**
   ```bash
   # Check ACR integration
   az aks show --resource-group "rg-blog-app" --name "aks-blog-app" --query "servicePrincipalProfile"
   
   # Re-attach ACR
   az aks update --resource-group "rg-blog-app" --name "aks-blog-app" --attach-acr "acrblogappsdk8s"
   ```

4. **External IP Pending**
   ```bash
   # Check load balancer events
   kubectl describe service blog-app-nodeport -n blog-app
   ```

### Debug Commands
```bash
# Pod status
kubectl describe pod <pod-name> -n blog-app

# Service endpoints
kubectl get endpoints -n blog-app

# Cluster info
kubectl cluster-info

# Node status
kubectl get nodes -o wide
```

## 🔐 Security Best Practices

### 1. Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: blog-app-netpol
  namespace: blog-app
spec:
  podSelector:
    matchLabels:
      app: blog-application
  policyTypes:
  - Ingress
  ingress:
  - from: []
    ports:
    - protocol: TCP
      port: 8080
```

### 2. Pod Security Context
Already configured in deployment.yaml:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  allowPrivilegeEscalation: false
```

### 3. Resource Limits
Already configured in deployment.yaml:
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "250m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

## 📖 Additional Resources

- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
