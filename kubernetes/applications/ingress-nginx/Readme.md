# Install with helm
helm upgrade ingress-nginx ingress-nginx/ingress-nginx -f applications/ingress-nginx/values.yaml  -n ingress-nginx --create-namespace --install