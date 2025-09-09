# syntax=docker/dockerfile:1

FROM docker.io/library/ruby:3.4.5-alpine AS base

RUN apk --no-cache add jemalloc libcurl patchelf tzdata && \
    patchelf --add-needed libjemalloc.so.2 /usr/local/bin/ruby && \
    apk del patchelf && \
    addgroup -g 101 -S ruby && \
    adduser  -u 101 -S overnight -g overnight -G ruby -H && \
    mkdir -p /usr/src/app/lib/overnight && \
    chown -R overnight:ruby /usr/src/app && \
    chmod go-w,a-t "${GEM_HOME}"

WORKDIR /usr/src/app

FROM base AS dependencies

COPY lib/overnight/version.rb lib/overnight/
COPY Gemfile Gemfile.lock overnight.gemspec ./

RUN bundle config set --local frozen true && \
    bundle config set --local without 'development'

RUN apk --no-cache add --virtual build-dependencies build-base linux-headers && \
    bundle install && \
    rm -rf "${GEM_HOME}/cache" && \
    apk del build-dependencies

FROM base

COPY --from=dependencies /usr/local/bundle/ /usr/local/bundle/
COPY --chown=overnight . .

USER overnight

CMD ["bin/overnight", "--push-notifications"]
