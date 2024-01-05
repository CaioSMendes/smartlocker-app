# Use a imagem Ruby com Alpine como base
FROM ruby:3.1.2


# Instala as dependências necessárias
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    tzdata \
    nodejs \
    yarn \
    postgresql-client

# Define o diretório de trabalho
WORKDIR /app

# Adiciona os arquivos Gemfile e Gemfile.lock para aproveitar o cache ao instalar gems
COPY Gemfile Gemfile.lock ./

# Instala o Bundler e as gems do projeto
RUN gem install rails bundler

RUN bundle install

# Adiciona o código do aplicativo ao contêiner
COPY . .

# Define variáveis de ambiente necessárias para o Rails e o PostgreSQL
#ENV RAILS_ENV=production
#ENV RAILS_SERVE_STATIC_FILES=true

# Expor a porta 3000 para a aplicação Rails

EXPOSE 3000

# Executa o script entrypoint.sh após o comando rails server
CMD ["sh", "-c", "rails server -b 0.0.0.0"]
