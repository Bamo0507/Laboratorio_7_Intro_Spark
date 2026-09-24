# Entorno del Lab 7: Python 3.11 + Java 17 + Spark 3.5 + Jupyter
# Basado en spark_practica-1. Debian bookworm para tener openjdk-17.
FROM python:3.11-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jdk-headless ca-certificates curl tini procps && \
    rm -rf /var/lib/apt/lists/* && \
    # ruta estable de Java sin importar la arquitectura (arm64 en Mac M, amd64 en Intel/Windows)
    ln -s /usr/lib/jvm/java-17-openjdk-$(dpkg --print-architecture) /usr/lib/jvm/java-17

ENV JAVA_HOME=/usr/lib/jvm/java-17
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV PYSPARK_PYTHON=/usr/local/bin/python

WORKDIR /opt/app

COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /tmp/requirements.txt

RUN useradd -ms /bin/bash spark && chown -R spark:spark /opt/app
USER spark

EXPOSE 8888 4040
ENTRYPOINT ["tini", "--"]
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--IdentityProvider.token=", "--ServerApp.password=", "--notebook-dir=/opt/app"]
