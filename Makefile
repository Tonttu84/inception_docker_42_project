ENV_FILE := ./srcs/.env
DATA_DIR := ./data

all: $(ENV_FILE) setup
	@$(MAKE) run

CFILE := srcs/docker-compose.yml
PROJECT := inception

# Second stage (env is guaranteed to exist)
run:
	@. $(ENV_FILE); \
	docker-compose -f srcs/docker-compose.yml -p inception up --build -d
	@echo "✅ Stack is running at https://localhost:8443"

$(ENV_FILE):
	@echo "⚠️  Creating default UNSAFE env file"
	@mkdir -p $(dir $(ENV_FILE))
	@echo "myMariaPass=unsafe" > $(ENV_FILE)
	@echo "MariaBossPass=unsafe" >> $(ENV_FILE)
	@echo "WriterPass=unsafe" >> $(ENV_FILE)
	@echo "BossPass=unsafe" >> $(ENV_FILE)
	@echo "WP_HOME=https://localhost:8443" >> $(ENV_FILE)
	@echo "WP_SITEURL=https://localhost:8443" >> $(ENV_FILE)

setup:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

clean:
	@docker-compose -f $(CFILE) -p $(PROJECT) down -v --remove-orphans || true
	@docker image prune -a -f || true
	@docker volume prune -f || true
	@docker builder prune -f || true
	@echo "✅ Docker environment cleaned (persistent data and .env kept)"

fclean: clean
	@echo "🧹 Performing full cleanup (persistent data and .env removed)..."
	# Remove .env
	@rm -f $(ENV_FILE) 2>/dev/null || true
	# Safely remove persistent data via Docker container (avoids host permission issues)
	@test -d $(DATA_DIR) && docker run --rm -v $(PWD)/$(DATA_DIR):/data alpine sh -c "rm -rf /data/*" || true
	@echo "✅ Full cleanup done"

re:
	@$(MAKE) clean
	@$(MAKE) all

.PHONY: all run setup fclean re
