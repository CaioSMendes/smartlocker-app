#!/bin/bash
set -e

# Remover o pid do servidor caso exista
rm -f /app/tmp/pids/server.pid

# Executar o comando para criar o banco de dados
bundle exec rails db:create

# Executar o comando para migrar o banco de dados
bundle exec rails db:migrate

# Executar o comando para popular o banco de dados (se necessário)
bundle exec rails db:seed

# Executar o comando passado como argumento ou iniciar o servidor por padrão
exec "$@"
