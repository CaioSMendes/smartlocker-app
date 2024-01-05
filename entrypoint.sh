#!/bin/bash

# Configurações ou comandos anteriores, se necessário

# Executa as migrações do banco de dados
bundle exec rails db:migrate

# Executa o seed do banco de dados
bundle exec rails db:seed

# Inicia o servidor Rails
bundle exec rails server -b 0.0.0.0
