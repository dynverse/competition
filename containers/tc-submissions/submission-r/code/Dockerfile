FROM rocker/tidyverse

RUN apt-get update && apt-get install -y libhdf5-dev

RUN R -e 'install.packages("hdf5r")'

COPY main.R /code/

RUN chmod +x /code/*

ENTRYPOINT ["/code/main.R"]
