FROM python:3.10-slim as build-image

WORKDIR /root/poetry
COPY pyproject.toml poetry.lock /root/poetry/

RUN pip install wheel poetry --no-cache-dir

ENV VENV_PATH=/opt/venv

RUN python -m venv $VENV_PATH \
    && poetry export --without-hashes > requirements.txt \
    && . /opt/venv/bin/activate \
    && pip install -r requirements.txt --no-cache-dir


FROM python:3.10-slim as runtime-image

WORKDIR /app

ENV VENV_PATH=/opt/venv
ENV PATH="$VENV_PATH/bin:$PATH"

COPY ./app/ /app/

COPY --from=build-image $VENV_PATH $VENV_PATH

EXPOSE 8000

CMD gunicorn app.wsgi
