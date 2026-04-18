#!/bin/bash
set -e

echo "=== 0. Настройка Istio Service Mesh ==="

# Устанавливаем istioctl если отсутствует
if ! command -v istioctl &>/dev/null; then
  echo "istioctl не найден, скачиваем..."
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.21.0 sh -
  export PATH="$PWD/istio-1.21.0/bin:$PATH"
fi

# Устанавливаем Istio в кластер (demo-профиль)
echo "--- Устанавливаем Istio в кластер..."
istioctl install --set profile=demo -y

# Включаем автоматическую инъекцию sidecar для default namespace
echo "--- Включаем sidecar injection для namespace default..."
kubectl label namespace default istio-injection=enabled --overwrite

# Ждём готовности Istio компонентов
echo "--- Ожидаем готовности istiod..."
kubectl rollout status deployment/istiod -n istio-system --timeout=120s

echo "--- Ожидаем готовности istio-ingressgateway..."
kubectl rollout status deployment/istio-ingressgateway -n istio-system --timeout=120s

echo "=== 1. Собираем Docker образ ==="
docker build -t custom-app-image:latest ./app

echo "=== 2. Применяем настройки ==="
kubectl apply -f k8s/01-configmap.yaml

echo "=== 2.5 Тестовый Pod  ==="
kubectl apply -f k8s/01-5-pod.yaml

echo "=== 3. Разворачиваем приложение ==="
kubectl apply -f k8s/02-app.yaml

echo "=== 4. Запускаем сборщик логов (DaemonSet) ==="
kubectl apply -f k8s/03-daemonset.yaml

echo "=== 5. Настраиваем архивацию (CronJob) ==="
kubectl apply -f k8s/04-cronjob.yaml

echo "=== 6. Применяем Istio конфигурации ==="
kubectl apply -f k8s/05-gateway.yaml
kubectl apply -f k8s/06-virtualservice.yaml
kubectl apply -f k8s/07-destinationrule-app.yaml
kubectl apply -f k8s/08-destinationrule-log.yaml

echo "=== 7. Ожидание готовности ключевых компонентов... ==="
kubectl wait --for=condition=ready pod/test-app-pod --timeout=60s

kubectl rollout status deployment/my-app

echo "=== 8. Перезапуск при изменении конфига ==="
kubectl rollout restart deployment my-app
kubectl rollout status deployment/my-app

echo "=== Готово! === "
echo "Для проверки API выполни: kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80"
echo "Внешний IP Istio Ingress:   kubectl get svc istio-ingressgateway -n istio-system"
