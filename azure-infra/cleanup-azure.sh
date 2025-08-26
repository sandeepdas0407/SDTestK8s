#!/bin/bash

echo "🧹 Cleaning up Azure AKS resources..."

RESOURCE_GROUP="rg-blog-app"

# Check if Azure CLI is logged in
if ! az account show &> /dev/null; then
    echo "❌ Please login to Azure CLI first: az login"
    exit 1
fi

# Delete the entire resource group
echo "🗑️  Deleting resource group: $RESOURCE_GROUP"
echo "⚠️  This will delete ALL resources in the resource group!"
read -p "Are you sure? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    az group delete --name $RESOURCE_GROUP --yes --no-wait
    echo "✅ Resource group deletion initiated"
    echo "🕐 Resources are being deleted in the background"
    echo "   You can check status with: az group show --name $RESOURCE_GROUP"
else
    echo "❌ Cleanup cancelled"
fi
