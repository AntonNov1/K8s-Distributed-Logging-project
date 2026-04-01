#!/bin/bash



set -e



echo "=== 1. Собираем Docker образ ==="

docker build -t custom-app-image:latest ./app



echo "=== 2. Применяем настройки (ConfigMap) ==="

kubectl apply -f k8s/01-configmap.yaml



echo "=== 3. Разворачиваем приложение (Deployment & Service) ==="

kubectl apply -f k8s/02-app.yaml



echo "=== 4. Запускаем сборщик логов (DaemonSet) ==="

kubectl apply -f k8s/03-daemonset.yaml



echo "=== 5. Настраиваем архивацию (CronJob) ==="

kubectl apply -f k8s/04-cronjob.yaml



echo "=== Готово! === "

echo "Проверить поды можно командой: kubectl get pods"

echo "Чтобы пробросить порт и проверить API, выполни:"

echo "kubectl port-forward svc/app-service 8080:80"
