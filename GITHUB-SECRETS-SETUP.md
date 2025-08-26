# 🔐 GitHub Secrets Setup Guide

This document explains how to set up the required secrets for the CI/CD pipeline.

## 📋 Required Secrets

### 🔑 **AZURE_CREDENTIALS**
Azure Service Principal credentials for GitHub Actions to access Azure resources.

**To create:**
```bash
# Create a service principal
az ad sp create-for-rbac --name "github-actions-blog-app" \
  --role Contributor \
  --scopes /subscriptions/{subscription-id}/resourceGroups/rg-blog-app \
  --sdk-auth

# Output will be JSON like this (save it as AZURE_CREDENTIALS secret):
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "activeDirectoryGraphResourceId": "https://graph.windows.net/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

### 🔑 **ACR_USERNAME**
Azure Container Registry username.

**To get:**
```bash
az acr credential show --name acrblogappsdk8s --query "username" -o tsv
```

### 🔑 **ACR_PASSWORD**
Azure Container Registry password.

**To get:**
```bash
az acr credential show --name acrblogappsdk8s --query "passwords[0].value" -o tsv
```

## ⚙️ How to Add Secrets to GitHub

1. Go to your GitHub repository
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. Add each secret with the exact name and value

## 🔍 Secret Names Required:

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `AZURE_CREDENTIALS` | Service Principal JSON | `az ad sp create-for-rbac` command |
| `ACR_USERNAME` | Container Registry username | `az acr credential show` command |
| `ACR_PASSWORD` | Container Registry password | `az acr credential show` command |

## 🌍 Environment Setup

### Production Environment
- Branch: `main`
- Namespace: `blog-app`
- Deployment: Automatic on push to main

### Development Environment  
- Branch: `develop`
- Namespace: `blog-app-dev`
- Deployment: Automatic on push to develop

## 🔐 Security Best Practices

1. **Least Privilege**: Service principal has minimal required permissions
2. **Environment Separation**: Different namespaces for dev/prod
3. **Secret Rotation**: Rotate ACR credentials regularly
4. **Branch Protection**: Require PR reviews for main branch
5. **Approval Gates**: Production deployments require manual approval

## 🚀 Pipeline Triggers

### Automatic Triggers:
- **Push to main**: Builds, tests, and deploys to production
- **Push to develop**: Builds, tests, and deploys to development
- **Pull Request**: Runs validation tests only

### Manual Triggers:
- **Infrastructure Deployment**: Deploy/destroy Azure infrastructure
- **Workflow Dispatch**: Manual deployment triggers

## 📝 Setup Checklist

- [ ] Create Azure Service Principal
- [ ] Add AZURE_CREDENTIALS secret
- [ ] Get ACR credentials
- [ ] Add ACR_USERNAME secret
- [ ] Add ACR_PASSWORD secret
- [ ] Create main and develop branches
- [ ] Set up branch protection rules
- [ ] Configure environment approvals (optional)
- [ ] Test pipeline with a commit

## 🎯 Next Steps

1. **Push code to GitHub**
2. **Add required secrets**
3. **Create develop branch**
4. **Make a test commit to trigger pipeline**
5. **Monitor deployment in Actions tab**

Your CI/CD pipeline will automatically:
- ✅ Build and test your application
- ✅ Create Docker images
- ✅ Push to Azure Container Registry  
- ✅ Deploy to Kubernetes
- ✅ Run security scans
- ✅ Provide deployment status
