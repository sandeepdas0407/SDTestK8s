# 🚀 GitHub Repository & CI/CD Setup

This guide will help you create a GitHub repository and set up automated CI/CD deployments.

## 📋 Prerequisites

- GitHub account
- Azure CLI installed and logged in
- Git installed locally
- Current project optimized and ready

## 🎯 Step-by-Step Setup

### 1. Create GitHub Repository

**Option A: Using GitHub Web Interface**
1. Go to [GitHub.com](https://github.com)
2. Click **"New"** or **"+"** → **"New repository"**
3. Repository name: `blog-app-k8s` (or your preferred name)
4. Description: `ASP.NET Core Blog Application with Kubernetes and Azure deployment`
5. Set to **Public** or **Private** (your choice)
6. ❌ **Don't** initialize with README (we have files already)
7. Click **"Create repository"**

**Option B: Using GitHub CLI** (if installed)
```bash
gh repo create blog-app-k8s --public --description "ASP.NET Core Blog Application with Kubernetes and Azure deployment"
```

### 2. Connect Local Repository

```bash
# Add remote origin (replace with your repository URL)
git remote add origin https://github.com/YOUR_USERNAME/blog-app-k8s.git

# Verify remote
git remote -v
```

### 3. Create Initial Commit

```bash
# Add all files
git add .

# Create initial commit
git commit -m "🚀 Initial commit: Blog app with K8s deployment and CI/CD pipeline

✅ ASP.NET Core 9.0 blog application
✅ Docker containerization
✅ Kubernetes manifests
✅ Azure infrastructure (Bicep)
✅ GitHub Actions CI/CD pipeline
✅ Project optimization complete

Features:
- Complete CRUD blog functionality
- Production-ready Kubernetes deployment
- Azure Container Registry integration
- Automated CI/CD with GitHub Actions
- Multi-environment support (dev/prod)
- Security scanning included"

# Push to GitHub
git push -u origin main
```

### 4. Create Development Branch

```bash
# Create and switch to develop branch
git checkout -b develop

# Push develop branch
git push -u origin develop
```

### 5. Set Up Azure Service Principal

```bash
# Get your subscription ID
az account show --query "id" -o tsv

# Create service principal (replace SUBSCRIPTION_ID)
az ad sp create-for-rbac --name "github-actions-blog-app" \
  --role Contributor \
  --scopes /subscriptions/SUBSCRIPTION_ID/resourceGroups/rg-blog-app \
  --sdk-auth
```

**Save the JSON output** - you'll need it for GitHub secrets!

### 6. Get ACR Credentials

```bash
# Get ACR username
az acr credential show --name acrblogappsdk8s --query "username" -o tsv

# Get ACR password
az acr credential show --name acrblogappsdk8s --query "passwords[0].value" -o tsv
```

### 7. Configure GitHub Secrets

1. Go to your GitHub repository
2. **Settings** → **Secrets and variables** → **Actions**
3. Add these secrets:

| Secret Name | Value | Source |
|-------------|-------|--------|
| `AZURE_CREDENTIALS` | Full JSON from service principal | Step 5 output |
| `ACR_USERNAME` | ACR username | Step 6 first command |
| `ACR_PASSWORD` | ACR password | Step 6 second command |

### 8. Set Up Branch Protection (Optional but Recommended)

1. **Settings** → **Branches**
2. **Add rule** for `main` branch:
   - ✅ Require pull request reviews
   - ✅ Require status checks to pass
   - ✅ Require branches to be up to date
   - ✅ Include administrators

### 9. Configure Environments (Optional)

1. **Settings** → **Environments**
2. Create **"production"** environment:
   - ✅ Required reviewers (add yourself)
   - ⏱️ Wait timer: 0 minutes
3. Create **"development"** environment:
   - No restrictions needed

## 🎯 Testing Your CI/CD Pipeline

### Test 1: Development Deployment
```bash
# Switch to develop branch
git checkout develop

# Make a small change
echo "# Development Test" >> README.md

# Commit and push
git add .
git commit -m "🧪 Test development deployment"
git push
```

### Test 2: Production Deployment
```bash
# Switch to main branch
git checkout main

# Merge develop changes
git merge develop

# Push to trigger production deployment
git push
```

### Test 3: Pull Request Workflow
```bash
# Create feature branch
git checkout -b feature/test-pr

# Make changes
echo "# Feature Test" >> README.md

# Commit and push
git add .
git commit -m "✨ Add feature test"
git push -u origin feature/test-pr

# Create PR on GitHub web interface
```

## 📊 Pipeline Overview

### 🔄 **Automatic Workflows:**

#### **Push to `main`:**
1. ✅ Build & Test (.NET application)
2. ✅ Build Docker Image
3. ✅ Push to Azure Container Registry
4. ✅ Deploy to Production (blog-app namespace)
5. ✅ Security Scan
6. ✅ Apply LoadBalancer service

#### **Push to `develop`:**
1. ✅ Build & Test (.NET application)
2. ✅ Build Docker Image (tagged as 'develop')
3. ✅ Push to Azure Container Registry
4. ✅ Deploy to Development (blog-app-dev namespace)

#### **Pull Request:**
1. ✅ Build & Test validation
2. ✅ Code quality checks
3. ✅ Docker build validation
4. ✅ Kubernetes manifest validation
5. ✅ PR comment with results

### 🛠️ **Manual Workflows:**

#### **Infrastructure Deployment:**
- Deploy or destroy Azure infrastructure
- Manual trigger via GitHub Actions
- Environment selection (prod/dev)

## 🎉 Success Indicators

After setup, you should see:

1. **GitHub Actions tab** showing successful workflows
2. **Azure Container Registry** with new image versions
3. **AKS cluster** with updated deployments
4. **Application accessible** at LoadBalancer IP
5. **Automated deployments** on code changes

## 🔍 Monitoring & Logs

### View Deployment Status:
```bash
# Check AKS deployments
kubectl get deployments -n blog-app
kubectl get deployments -n blog-app-dev

# Check services
kubectl get services -n blog-app
kubectl get services -n blog-app-dev

# View application logs
kubectl logs -f deployment/blog-app-deployment -n blog-app
```

### GitHub Actions Monitoring:
- **Actions tab**: View workflow runs
- **Email notifications**: GitHub will email on failures
- **Status badges**: Add to README for build status

## 🚨 Troubleshooting

### Common Issues:

1. **Secret not found**: Verify secret names match exactly
2. **Azure login failed**: Check AZURE_CREDENTIALS format
3. **ACR push failed**: Verify ACR_USERNAME and ACR_PASSWORD
4. **Deployment failed**: Check AKS cluster status
5. **Image pull failed**: Ensure ACR is attached to AKS

### Debug Commands:
```bash
# Check service principal
az ad sp show --id <CLIENT_ID>

# Test ACR login
docker login acrblogappsdk8s.azurecr.io

# Check AKS connection
az aks get-credentials --resource-group rg-blog-app --name aks-blog-app
```

## 🎊 You're All Set!

Your repository now has:
- ✅ **Automated CI/CD pipeline**
- ✅ **Multi-environment deployments**
- ✅ **Security scanning**
- ✅ **Pull request validation**
- ✅ **Infrastructure automation**

**Every code change will now automatically deploy to Azure! 🚀**
