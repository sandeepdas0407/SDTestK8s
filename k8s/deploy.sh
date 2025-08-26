#!/bin/bash

echo "🚀 Deploying Blog Application to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    echo "Please install kubectl: https://kubernetes.io/docs/tasks/tools/"
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please ensure your cluster is running and kubectl is configured"
    exit 1
fi

echo "✅ Kubernetes cluster is accessible"

# Build and load Docker image first
echo "📦 Building Docker image..."
cd ..
./build-docker.sh

if [ $? -ne 0 ]; then
    echo "❌ Failed to build Docker image"
    exit 1
fi

# Load image into cluster (for local development)
echo "📥 Loading image into cluster..."
# For minikube
if command -v minikube &> /dev/null && minikube status | grep -q "Running"; then
    minikube image load blog-app:latest
    echo "✅ Image loaded into minikube"
# For kind
elif command -v kind &> /dev/null; then
    kind load docker-image blog-app:latest
    echo "✅ Image loaded into kind cluster"
fi

cd k8s

echo "🔧 Applying Kubernetes manifests..."

# Apply all manifests
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Optional: Apply HPA if metrics server is available
if kubectl get apiservice v1beta1.metrics.k8s.io &> /dev/null; then
    kubectl apply -f hpa.yaml
    echo "✅ HPA applied"
else
    echo "⚠️  Metrics server not found, skipping HPA"
fi

# Optional: Apply Ingress if ingress controller is available
if kubectl get ingressclass &> /dev/null; then
    kubectl apply -f ingress.yaml
    echo "✅ Ingress applied"
else
    echo "⚠️  No ingress controller found, skipping Ingress"
fi

echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/blog-app-deployment -n blog-app

if [ $? -eq 0 ]; then
    echo "🎉 Deployment successful!"
    echo ""
    echo "📊 Deployment Status:"
    kubectl get pods -n blog-app
    echo ""
    echo "🌐 Access your application:"
    echo "   NodePort: http://localhost:30080"
    echo "   Port Forward: kubectl port-forward service/blog-app-service 8080:80 -n blog-app"
    echo ""
    echo "📋 Useful commands:"
    echo "   kubectl get all -n blog-app"
    echo "   kubectl logs -f deployment/blog-app-deployment -n blog-app"
    echo "   kubectl delete namespace blog-app"
else
    echo "❌ Deployment failed or timed out"
    kubectl get pods -n blog-app
    exit 1
fi
