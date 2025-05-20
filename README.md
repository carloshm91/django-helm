# Django Helm Chart

A flexible Helm chart for deploying Django applications on Kubernetes with support for external services.

## Features

- Complete Django deployment with configurable components
- Support for external services (Redis, RabbitMQ, Database)
- Celery workers and beat scheduler
- MQTT broker
- Automatic migrations and static file collection
- Horizontal Pod Autoscaling
- Flexible configuration options

## Quick Start

```bash
# Add the Helm repository
helm repo add django-helm https://yourusername.github.io/django-helm

# Update repository
helm repo update

# Install the chart
helm install my-django-app django-helm/django-app \
  --set image.repository=your-registry/your-image \
  --set image.tag=latest \
  --set database.host=your-db-host \
  --set database.name=your-db-name \
  --set database.user=your-db-user \
  --set envSecrets.create=false