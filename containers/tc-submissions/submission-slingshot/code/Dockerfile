FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

RUN apt-get update && apt-get install -y libcgal-dev libglu1-mesa-dev libgsl-dev

COPY main.R /code/

RUN R -e 'BiocManager::install("slingshot")'

RUN chmod +x /code/*

ENTRYPOINT ["/code/main.R"]
