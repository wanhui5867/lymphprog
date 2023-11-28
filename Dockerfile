FROM rocker/shiny:latest

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git libxml2-dev libmagick++-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Command to install standard R packages from CRAN; enter the list of required packages for your app here
RUN Rscript -e 'install.packages(c("shiny","tidyverse","BiocManager", "ggplot2", "DT", "bslib","plotly", "ggpubr", "ggrepel","devtools"))'

# Command to install gridlayout
RUN Rscript -e 'devtools::install_github("rstudio/gridlayout")'

# Command to install packages from Bioconductor; enter the list of required Bioconductor packages for your app here
RUN Rscript -e 'BiocManager::install("preprocessCore", configure.args = c(preprocessCore = "--disable-threading"), force= TRUE, update=TRUE, type = "source")'

RUN rm -rf /srv/shiny-server/*
COPY /LymphProg/ /srv/shiny-server/

RUN mkdir /srv/shiny-server/app_cache/
RUN chown shiny /srv/shiny-server/app_cache/

USER shiny

EXPOSE 3838

CMD ["/usr/bin/shiny-server"]
