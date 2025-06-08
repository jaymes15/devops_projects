# Start the apilication
.PHONY: up
up:
	docker-compose up

# Stop and remove containers
.PHONY: down
down:
	docker-compose down

# Build the containers
.PHONY: build
build:
	docker-compose up --build

# Create a new api
.PHONY: startapi
startapi:
	docker-compose run --rm api sh -c "python manage.py startapi $(api)"

# Create superuser
.PHONY: createsuperuser
createsuperuser:
	docker-compose run --rm api sh -c "python manage.py createsuperuser"

# Run migrations
.PHONY: migrate
migrate:
	docker-compose run --rm api sh -c "python manage.py wait_for_db && python manage.py migrate"

# Create migrations
.PHONY: makemigrations
makemigrations:
	docker-compose run --rm api sh -c "python manage.py wait_for_db && python manage.py makemigrations"

# Create and apily migrations
.PHONY: migrate-all
migrate-all:
	docker-compose run --rm api sh -c "python manage.py wait_for_db && python manage.py makemigrations && python manage.py migrate"

# Run tests
.PHONY: test
test:
	docker-compose run --rm api sh -c "python manage.py wait_for_db && python manage.py test"

# Run linting
.PHONY: lint
lint:
	docker-compose run --rm api sh -c "flake8"

# Run tests and linting
.PHONY: test-lint
test-lint:
	docker-compose run --rm api sh -c "python manage.py wait_for_db && python manage.py test && flake8"

# Install new packages (requires rebuilding)
.PHONY: install
install:
	docker-compose up --build

# Sort imports
.PHONY: isort
isort:
	docker-compose run --rm api sh -c "isort ."

# Check sort imports
.PHONY: check-isort
check-isort:
	docker-compose run --rm api sh -c "isort --check-only ."

# Collect static files
.PHONY: collectstatic
collectstatic:
	docker-compose run --rm api sh -c "python manage.py collectstatic"