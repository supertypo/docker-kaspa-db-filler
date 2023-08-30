FROM python:3.10-alpine

ARG REPO_DIR

EXPOSE 8000

ENV KASPAD_HOST_1=kaspad:16110 \
  SQL_URI=postgresql://postgres:password@postgresql:5432/postgres

RUN apk --no-cache add \
  git \
  gcc \
  libc-dev \
  build-base \
  linux-headers \
  libpq-dev \
  dumb-init

RUN pip install \
  pipenv

RUN addgroup -S -g 55746 kaspa-db-filler \
  && adduser -h /app -S -D -g '' -G kaspa-db-filler -u 55746 kaspa-db-filler

WORKDIR /app

USER kaspa-db-filler

COPY --chown=kaspa-db-filler:kaspa-db-filler "$REPO_DIR" /app

RUN pipenv install --deploy -v

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD pipenv run python main.py
 
