NAME = inception

all: $(NAME)

$(NAME):
	@echo "Creating directories for volumes..."
	@mkdir -p /home/eel-abed/data/mariadb
	@mkdir -p /home/eel-abed/data/wordpress
	@echo "Building and starting containers in detached mode..."
	@docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build

down:
	@echo "Stopping containers..."
	@docker compose -f srcs/docker-compose.yml down

clean:
	@echo "Removing containers, networks, and anonymous volumes..."
	@docker compose -f srcs/docker-compose.yml down -v
	@docker system prune -a -f

fclean: clean
	@echo "Removing volume directories..."
	@sudo rm -rf /home/eel-abed/data/mariadb
	@sudo rm -rf /home/eel-abed/data/wordpress

re: fclean all

.PHONY: all down clean fclean re
