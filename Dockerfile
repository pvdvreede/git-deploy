FROM elixir:1.12 as dev
RUN apt-get update
RUN apt-get install -y docker-compose git git-crypt
RUN mix local.rebar --force && mix local.hex --force
WORKDIR /workspace


FROM debian
RUN apt-get update
RUN apt-get install -y docker-compose git git-crypt
