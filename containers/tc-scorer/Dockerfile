FROM dynverse/dynwrapr:v0.1.0

ARG GITHUB_PAT

WORKDIR /code

RUN apt-get update && \
  apt-get install -y curl && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash - && \
  sudo apt-get install -y nodejs

RUN R -e 'devtools::install_cran("prettyunits")'

RUN R -e 'devtools::install_github("dynverse/dyneval@devel", dep = T)'

COPY . .

ENTRYPOINT ["sudo", "./score.sh"]
