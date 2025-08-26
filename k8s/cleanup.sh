#!/bin/bash

echo "🧹 Cleaning up Blog Application from Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed or not in PATH"
    exit 1
fi

echo "🗑️  Deleting namespace and all resources..."
kubectl delete namespace blog-app

if [ $? -eq 0 ]; then
    echo "✅ Cleanup completed successfully!"
    echo "All blog-app resources have been removed from the cluster."
else
    echo "❌ Cleanup failed or namespace doesn't exist"
    exit 1
fi
