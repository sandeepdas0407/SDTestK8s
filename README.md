# Blog Application - Kubernetes Deployment

This repository contains a containerized ASP.NET Core 9.0 blog application with Kubernetes orchestration and Azure deployment capabilities.

## 🏗️ **Project Structure (Optimized)**

```
SDTestK8s/
├── 📁 WebApplication1/           # ASP.NET Core source code
├── 📁 azure-infra/              # Azure infrastructure (Bicep)
├── � k8s/                      # Kubernetes manifests
│   ├── k8s-all-in-one.yaml     # Complete deployment
│   ├── loadbalancer-service.yaml
│   ├── deploy.bat/sh            # Deployment scripts
│   └── cleanup.bat/sh
├── 📄 Dockerfile               # Container definition
├── 📄 build-docker.bat/sh      # Build scripts
└── 📄 README.md                # This file
```

## �🚀 Quick Start

### Prerequisites

- [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured
- A running Kubernetes cluster (AKS, Docker Desktop, minikube, etc.)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (for Azure deployment)

### Option 1: One-Command Deployment

**Windows:**
```cmd
cd k8s
deploy.bat
```

**Linux/Mac:**
```bash
cd k8s
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment Steps

1. **Build the Docker image:**
   ```bash
   cd WebApplication1
   dotnet publish -c Release -o ../publish --self-contained -r linux-x64
   cd ..
   ```

2. **Build the Docker image:**
   ```bash
   docker build -t blog-app .
   ```

3. **Deploy to Kubernetes:**
   ```bash
   kubectl apply -f k8s/k8s-all-in-one.yaml
   ```

4. **Access the application:**
   - **NodePort**: http://localhost:30080
   - **Port Forward**: `kubectl port-forward service/blog-app-service 8080:80 -n blog-app`

### Option 3: Using Individual Manifests

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/hpa.yaml        # Optional: if metrics server available
kubectl apply -f k8s/ingress.yaml    # Optional: if ingress controller available
```
   ```bash
   docker-compose up -d
   ```

3. **Stop the application:**
   ```bash
   docker-compose down
   ```

### Option 3: Using Build Scripts

**Windows:**
```cmd
build-docker.bat
```

**Linux/Mac:**
```bash
chmod +x build-docker.sh
./build-docker.sh
```

## 🐳 Docker Image Details

- **Base Image:** mcr.microsoft.com/dotnet/aspnet:9.0
- **Application Port:** 8080
- **Environment:** Production
- **Size:** ~210MB (optimized multi-stage build)

## 📊 Application Features

- ✅ Create, Read, Update, Delete blog posts
- ✅ Responsive web interface
- ✅ In-memory database with sample data
- ✅ RESTful API endpoints
- ✅ Health checks
- ✅ Production-ready configuration

## 🔧 Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `ASPNETCORE_ENVIRONMENT` | `Production` | Application environment |
| `ASPNETCORE_URLS` | `http://+:8080` | URLs the app listens on |

## 🏥 Health Checks

The application includes health checks available at:
- Health Check Endpoint: `GET /api/posts` (used by Docker)

## 📚 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/posts` | Get all blog posts |
| GET | `/api/posts/{id}` | Get specific post |
| POST | `/api/posts` | Create new post |
| PUT | `/api/posts/{id}` | Update existing post |
| DELETE | `/api/posts/{id}` | Delete post |

## 🛠️ Development

### Local Development (without Docker)

1. **Prerequisites:**
   - .NET 9.0 SDK

2. **Run the application:**
   ```bash
   cd WebApplication1
   dotnet run
   ```

3. **Access at:** http://localhost:5000

### Rebuilding the Docker Image

After making changes to the code:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up
```

## 🚀 Production Deployment

For production deployment, consider:

1. **Using a persistent database** (PostgreSQL, SQL Server, etc.)
2. **Adding environment-specific configuration**
3. **Implementing proper logging and monitoring**
4. **Using HTTPS/TLS certificates**
5. **Setting up load balancing for multiple instances**

### Example with External Database

```yaml
# docker-compose.prod.yml
version: '3.8'
services:
  blog-app:
    build: .
    ports:
      - "80:8080"
    environment:
      - ASPNETCORE_ENVIRONMENT=Production
      - ConnectionStrings__DefaultConnection=Server=db;Database=BlogApp;User=sa;Password=YourPassword123!
    depends_on:
      - db

  db:
    image: mcr.microsoft.com/mssql/server:2022-latest
    environment:
      - ACCEPT_EULA=Y
      - SA_PASSWORD=YourPassword123!
    volumes:
      - sqldata:/var/opt/mssql

volumes:
  sqldata:
```

## 🎯 **Project Optimization**

This project has been optimized for production use:
- ✅ **144MB saved** by removing build artifacts and duplicates
- ✅ **Simplified K8s deployment** with single all-in-one manifest
- ✅ **Streamlined structure** with essential files only
- ✅ **Maintained functionality** while reducing complexity

See `PROJECT-OPTIMIZATION-COMPLETE.md` for detailed optimization report.

## 🌐 **Live Application**

Your blog application is currently deployed and accessible at:
- **External URL**: http://4.246.233.15 (Azure LoadBalancer)
- **Features**: Full CRUD operations for blog posts
- **Status**: ✅ Production-ready and scalable

## 📝 Notes

- The application uses an **in-memory database** by default
- Data will be lost when the container stops
- For production, integrate with a persistent database
- The application includes **sample blog posts** on startup

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Docker
5. Submit a pull request

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
