.PHONY: init-db start stop restart migrate upgrade

init-db:
	docker-compose -f docker-compose.local.yml up -d postgres
	sleep 5
	docker-compose -f docker-compose.local.yml exec postgres psql -U finance_user -d finance_db -c "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";"

start:
	docker-compose -f docker-compose.local.yml up -d

stop:
	docker-compose -f docker-compose.local.yml down

restart: stop start

migrate:
	alembic revision --autogenerate -m "Initial migration"

upgrade:
	alembic upgrade head

run:
	uvicorn app.main:app --reload
