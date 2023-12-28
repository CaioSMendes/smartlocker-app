#!/bin/bash

# Executa as migrações do banco de dados
bundle exec rails db:migrate

# Executa o seed do banco de dados
bundle exec rails db:seed

# Inicia o servidor Rails ou outro comando, se necessário
exec "$@"