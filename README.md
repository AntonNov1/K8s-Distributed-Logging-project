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
   ```

2. Дождитесь завершения скрипта. Он автоматически установит Istio и применит все манифесты.

3. Для проверки API выполните port-forward:

   ```bash
   kubectl port-forward svc/istio-ingressgateway -n istio-system 8080:80
   ```



## Задание 2: Интеграция Istio Service Mesh

### Что было сделано

Добавлен Istio Service Mesh в существующую Kubernetes-систему. Реализованы управление трафиком, отказоустойчивость и защищённая межсервисная коммуникация.

### Новые файлы

| Файл | Описание |
|---|---|
| `k8s/05-gateway.yaml` | Istio Gateway — принимает HTTP-трафик на порт 80 |
| `k8s/06-virtualservice.yaml` | VirtualService — маршрутизация, fault injection, 404 |
| `k8s/07-destinationrule-app.yaml` | DestinationRule для `app-service` |
| `k8s/08-destinationrule-log.yaml` | DestinationRule для `log-service` |

`deploy.sh` обновлён: теперь устанавливает Istio и применяет все новые манифесты.

### Архитектура

```
Внешний трафик
      │
      ▼
 Istio Gateway (порт 80)
      │
      ▼
 VirtualService (my-app-vs)
      │
      ├── POST /log  ──► fault injection (delay 2s, timeout 1s, retries 2) ──► app-service
      ├── /*         ──► app-service
      └── остальное  ──► 404 Not Found
```

### Gateway (`05-gateway.yaml`)

Принимает входящий HTTP-трафик на порт 80 для всех хостов (`*`).

### VirtualService (`06-virtualservice.yaml`)

- **`POST /log`** — fault injection: задержка 2с, таймаут 1с, 2 повторные попытки. Используется для тестирования поведения при сбоях.
- **`/*`** — маршрутизация на `app-service`.
- **Catch-all** — возвращает `404 Not Found` для неизвестных маршрутов.

### DestinationRule (`07`, `08`)

Для `app-service` и `log-service`:

- Балансировка: `LEAST_CONN` (минимум активных соединений)
- Лимит TCP-соединений: 3
- Лимит ожидающих HTTP-запросов: 5
- TLS: `ISTIO_MUTUAL` (mTLS внутри mesh)

### Проверка работы

```bash
# Основной маршрут — 200 OK
curl http://localhost:8080/

# Неизвестный маршрут — 404
curl http://localhost:8080/wrong

# POST /log — 504 (таймаут из-за fault injection)
curl -X POST http://localhost:8080/log -H "Content-Type: application/json" -d '{"message":"test"}'

# Состояние Istio-объектов
kubectl get gateway,virtualservice,destinationrule

# Анализ конфигурации
istioctl analyze
```
