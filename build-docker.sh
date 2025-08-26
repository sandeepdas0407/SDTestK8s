#!/bin/bash

echo "Building Blog Application Docker Image..."

echo "Step 1: Publishing the application..."
cd WebApplication1
dotnet publish -c Release -o ../publish --self-contained -r linux-x64
cd ..

if [ $? -ne 0 ]; then
    echo "❌ Failed to publish application"
    exit 1
fi

echo "Step 2: Building Docker image..."
# Build the Docker image
docker build -t blog-app:latest .

if [ $? -eq 0 ]; then
    echo "✅ Docker image built successfully!"
    echo "📦 Image name: blog-app:latest"
    echo ""
    echo "To run the container:"
    echo "  docker run -p 8080:8080 blog-app:latest"
    echo ""
    echo "Or use Docker Compose:"
    echo "  docker-compose up"
    echo ""
    echo "The application will be available at: http://localhost:8080"
else
    echo "❌ Failed to build Docker image"
    exit 1
fi
