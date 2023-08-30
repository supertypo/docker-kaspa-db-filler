##
# builder image
##
FROM python:3.10-slim AS builder

ARG REPO_DIR

ENV APP_USER=kaspa-db-filler \
  APP_UID=55746 \
  APP_DIR=/app

ENV KASPAD_HOST_1=kaspad:16110 \
  SQL_URI=postgresql://postgres:password@postgresql:5432/postgres

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    gcc \
    libc6-dev \
    libpq-dev \
    dumb-init

RUN pip install \
  pipenv

RUN groupadd -r -g $APP_UID $APP_USER && \
  useradd -d $APP_DIR -r -m -s /sbin/nologin -g $APP_USER -u $APP_UID $APP_USER

WORKDIR $APP_DIR
USER $APP_USER

COPY --chown=$APP_USER:$APP_USER "$REPO_DIR" $APP_DIR

RUN pipenv install --deploy -v
RUN rm -r .cache/

##
# kaspa-db-filler image
##
FROM python:3.10-slim

ENV APP_USER=kaspa-db-filler \
  APP_UID=55746 \
  APP_DIR=/app

ENV KASPAD_HOST_1=kaspad:16110 \
  SQL_URI=postgresql://postgres:password@postgresql:5432/postgres

RUN apt-get update && \
  apt-get install -y --no-install-recommends \
    libpq-dev \
    dumb-init && \
  rm -rf /var/lib/apt/lists/* 

RUN pip install \
  pipenv

RUN groupadd -r -g $APP_UID $APP_USER && \
  useradd -d $APP_DIR -r -m -s /sbin/nologin -g $APP_USER -u $APP_UID $APP_USER 

WORKDIR $APP_DIR
USER $APP_USER

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD pipenv run python main.py

COPY --chown=kaspa-db-filler:kaspa-db-filler --from=builder /app /app

