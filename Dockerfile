FROM elixir:1.12 as dev
RUN apt-get update
RUN apt-get install -y docker-compose git git-crypt
RUN mix local.rebar --force && mix local.hex --force
WORKDIR /workspace

FROM dev as build
COPY . /workspace/
ENV MIX_ENV prod
RUN mix deps.get
RUN mix compile
RUN mix release

FROM debian:bullseye
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get update && \
    apt-get install -y docker-compose git git-crypt && \
    apt-get clean
COPY --from=build /workspace/_build/prod/rel/git_deploy/ /app/.
CMD [ "/app/bin/git_deploy", "start" ]
