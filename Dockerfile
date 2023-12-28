# Use a imagem base do Ruby 3.1.2
FROM ruby:3.1.2

# Configuração do ambiente
ENV LANG C.UTF-8
ENV RAILS_ENV production

# Instalação das dependências
RUN apt-get update -qq && \
    apt-get install -y build-essential libpq-dev nodejs

# Criação do diretório de trabalho
WORKDIR /app

# Copia os arquivos do aplicativo para o contêiner
COPY Gemfile Gemfile.lock ./

# Instalação das gemas e das dependências do aplicativo
RUN gem install bundler && bundle install --jobs 20 --retry 5

# Pré-compilação dos assets (opcional, dependendo do seu aplicativo)
#RUN bundle exec rake assets:precompile

# Exponha a porta 3000 (ou a porta que você está usando)
EXPOSE 3000

# Comando para iniciar o servidor Rails
CMD ["rails", "server", "-b", "0.0.0.0"]
