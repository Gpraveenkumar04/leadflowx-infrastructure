#!/bin/bash

# Health check script for monitoring system components

check_component() {
    local component=$1
    local endpoint=$2
    
    echo "Checking $component..."
    response=$(curl -s -o /dev/null -w "%{http_code}" $endpoint)
    
    if [ $response -eq 200 ]; then
        echo "✅ $component is healthy"
        return 0
    else
        echo "❌ $component is not responding"
        return 1
    fi
}

# Component health checks
check_component "Prometheus" "http://localhost:9090/-/healthy"
check_component "Grafana" "http://localhost:3000/api/health"
check_component "Scraper" "http://localhost:8080/health"
check_component "Database" "http://localhost:5432"

# Check alert manager
if [ -f "/tmp/alertmanager.yml" ]; then
    echo "✅ Alert Manager configuration is present"
else
    echo "❌ Alert Manager configuration is missing"
fi

# Check Grafana dashboards
if [ -d "./grafana/dashboards" ]; then
    echo "✅ Grafana dashboards directory exists"
    dashboard_count=$(ls -1 ./grafana/dashboards/*.json 2>/dev/null | wc -l)
    echo "📊 Found $dashboard_count dashboards"
else
    echo "❌ Grafana dashboards directory is missing"
fi
