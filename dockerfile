# 1. Base Spark (Python 3.10)
FROM spark:3.5.0-scala2.12-java17-python3-ubuntu

USER root

# 2. Instalamos dependencias
RUN set -ex; \
    apt-get update && \
    apt-get install -y python3-pip python3-dev && \
    rm -rf /var/lib/apt/lists/*

# 3. Instalamos Jupyter y librerías
RUN pip3 install --no-cache-dir \
    jupyterlab \
    pandas \
    matplotlib \
    seaborn \
    requests \
    pyspark==3.5.0

# 4. Variables de entorno Spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=jupyter

RUN wget https://jdbc.postgresql.org/download/postgresql-42.6.0.jar && \
    cp postgresql-42.6.0.jar $SPARK_HOME/jars/ && \
    rm postgresql-42.6.0.jar

# --- CREACIÓN DE USUARIO JOVYAN ESTÁNDAR ---
# Creamos usuario con home (-m) y shell bash
RUN useradd -ms /bin/bash -u 1000 jovyan

# Definimos el directorio de trabajo ESTÁNDAR de Jupyter
WORKDIR /home/jovyan/work

# Le damos permisos a Jovyan sobre todo su home y sobre Spark (por si acaso genera logs ahí)
RUN chown -R jovyan:jovyan /home/jovyan && \
    chown -R jovyan:jovyan /opt/spark/work-dir

# Cambiamos al usuario Jovyan
USER jovyan
# -------------------------------------------

EXPOSE 8888 4040

# Comando de arranque (usando la variable de entorno para el token)
CMD ["sh", "-c", "jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --NotebookApp.token=\"${JUPYTER_TOKEN}\""]