# K8s Distributed Logging & Storage Project



Это учебный проект, демонстрирующий работу базовых сущностей Kubernetes: Deployment, Service, ConfigMap, DaemonSet и CronJob.



## Структура проекта

- `/app` - Исходный код Python Flask приложения и Dockerfile.

- `/k8s` - Манифесты Kubernetes (YAML файлы).



## Как запустить



**Важно:** Если вы используете `minikube`, перед запуском скрипта выполните команду `eval $(minikube docker-env)`, чтобы Docker собрал образ внутри виртуальной машины minikube.



1. Запустите скрипт автоматического развертывания:

   ```bash

   ./deploy.sh
