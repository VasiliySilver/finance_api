# Makefile для управления проектом Finance API

# Переменные окружения
ENV_FILE := .env
include $(ENV_FILE)
export

# Docker-compose файл для локального окружения
DOCKER_COMPOSE_FILE := docker-compose.local.yml

# Цель по умолчанию
.DEFAULT_GOAL := help

# Команда help
.PHONY: help
help:
	@echo "Доступные команды:"
	@echo ""
	@echo "  init-db       Инициализация базы данных (запуск PostgreSQL, создание расширения uuid-ossp)"
	@echo "  start         Запуск всех контейнеров (PostgreSQL и PGAdmin)"
	@echo "  stop          Остановка всех контейнеров"
	@echo "  restart       Перезапуск всех контейнеров"
	@echo "  logs          Просмотр логов контейнеров в реальном времени"
	@echo ""
	@echo "  migrate       Создание новой миграции на основе изменений в моделях"
	@echo "  upgrade       Применение всех pending-миграций"
	@echo "  downgrade     Откат последней примененной миграции"
	@echo "  history       Показ истории всех миграций"
	@echo "  current       Показ текущей версии миграции"
	@echo ""
	@echo "  run           Запуск FastAPI приложения локально с hot-reload"
	@echo "  run-docker    Сборка и запуск FastAPI в Docker-контейнере"
	@echo ""
	@echo "  test          Запуск всех тестов"
	@echo "  test-coverage Запуск тестов с показом покрытия кода"
	@echo ""
	@echo "  clean         Очистка временных файлов (кеши, покрытие и т.д.)"
	@echo "  clean-docker  Очистка Docker-окружения (удаление контейнеров, volumes и ненужных образов)"
	@echo ""
	@echo "  setup         Полная инициализация проекта (запуск базы данных, создание и применение миграций)"
	@echo "  help          Показ этого сообщения"
	@echo ""

# Команды для работы с Docker
.PHONY: init-db start stop restart logs

init-db:
	@echo "Инициализация базы данных..."
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d postgres
	@sleep 5  # Ждем, пока PostgreSQL запустится
	docker compose -f $(DOCKER_COMPOSE_FILE) exec postgres psql -U finance_user -d finance_db -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"
	@echo "База данных готова!"

start:
	@echo "Запуск контейнеров..."
	docker compose -f $(DOCKER_COMPOSE_FILE) up -d

stop:
	@echo "Остановка контейнеров..."
	docker compose -f $(DOCKER_COMPOSE_FILE) down

restart: stop start

logs:
	@echo "Просмотр логов..."
	docker compose -f $(DOCKER_COMPOSE_FILE) logs -f

# Команды для работы с Alembic
.PHONY: migrate upgrade downgrade history current

migrate:
	@echo "Создание новой миграции..."
	alembic revision --autogenerate -m "New migration"

upgrade:
	@echo "Применение миграций..."
	alembic upgrade head

downgrade:
	@echo "Откат последней миграции..."
	alembic downgrade -1

history:
	@echo "История миграций:"
	alembic history --verbose

current:
	@echo "Текущая версия миграции:"
	alembic current

# Команды для запуска приложения
.PHONY: run run-docker

run:
	@echo "Запуск FastAPI приложения..."
	uvicorn app.main:app --reload

run-docker:
	@echo "Запуск FastAPI в Docker..."
	docker compose -f $(DOCKER_COMPOSE_FILE) up --build

# Команды для тестирования
.PHONY: test test-coverage

test:
	@echo "Запуск тестов..."
	pytest tests/

test-coverage:
	@echo "Запуск тестов с покрытием..."
	pytest --cov=app tests/

# Команды для очистки
.PHONY: clean clean-docker

clean:
	@echo "Очистка временных файлов..."
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name ".pytest_cache" -exec rm -rf {} +
	rm -rf .mypy_cache
	rm -rf .coverage

clean-docker:
	@echo "Очистка Docker-окружения..."
	docker compose -f $(DOCKER_COMPOSE_FILE) down -v --remove-orphans
	docker system prune -f

# Команда для инициализации проекта
.PHONY: setup

setup: init-db migrate upgrade
	@echo "Проект успешно инициализирован!"