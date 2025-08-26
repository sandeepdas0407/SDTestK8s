# Simple Dockerfile using pre-published self-contained app
FROM ubuntu:22.04

# Install necessary runtime dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    libicu70 \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy the self-contained published application
COPY publish/ .

# Expose port
EXPOSE 8080

# Set environment variables
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Make the application executable
RUN chmod +x ./WebApplication1

# Run the application
ENTRYPOINT ["./WebApplication1"]
