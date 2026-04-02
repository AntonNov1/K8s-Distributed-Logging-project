#!/bin/bash
set -e

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

echo "=== 6. Ожидание готовности ключевых компонентов... ==="
kubectl wait --for=condition=ready pod/test-app-pod --timeout=60s

kubectl rollout status deployment/my-app

echo "=== 7. Перезапуск при изменении конфига ==="
kubectl rollout restart deployment my-app
kubectl rollout status deployment/my-app

echo "=== Готово! === "
echo "Для проверки API выполни: kubectl port-forward svc/app-service 8080:80"

