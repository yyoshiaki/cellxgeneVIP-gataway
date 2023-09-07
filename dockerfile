FROM continuumio/miniconda3

COPY environment.yml .
RUN conda env create -f environment.yml

RUN conda init bash
# RUN echo `conda info -e`
# RUN conda activate VIP_py3.9_pandoc
SHELL ["conda", "run", "-n", "VIP_py3.9_pandoc", "/bin/bash", "-c"]

RUN apt update
RUN apt install jq nodejs npm node-gyp dirmngr gnupg apt-transport-https ca-certificates software-properties-common cpio -y

RUN gpg --keyserver keyserver.ubuntu.com \
    --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
RUN gpg --armor --export '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' | \
    tee /etc/apt/trusted.gpg.d/cran_debian_key.asc
RUN add-apt-repository 'deb http://cloud.r-project.org/bin/linux/debian bullseye-cran40/'
RUN apt update
RUN apt install r-base libfontconfig1-dev libharfbuzz-dev libfribidi-dev libcurl4-openssl-dev libxml2-dev \
    libssl-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev libcairo2-dev libxt-dev -y
RUN apt install build-essential cmake -y

ENV LIBARROW_MINIMAL=false

RUN git clone https://github.com/interactivereport/cellxgene_VIP.git

WORKDIR /cellxgene_VIP
COPY config_mod.sh ./
RUN bash ./config_mod.sh

RUN which R

RUN R -q -e 'if(!require(devtools)) install.packages("devtools",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(Cairo)) devtools::install_version("Cairo",version="1.5-12",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(foreign)) devtools::install_version("foreign",version="0.8-76",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(ggpubr)) devtools::install_version("ggpubr",version="0.3.0",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(ggrastr)) devtools::install_version("ggrastr",version="0.2.1",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(arrow)) devtools::install_version("arrow",version="2.0.0",repos = "http://cran.us.r-project.org")'
# RUN R -q -e 'remotes::install_version("spatstat", version = "1.64-1")'
# RUN R -q -e 'if(!require(Seurat)) devtools::install_version("Seurat",version="3.2.3",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'install.packages(c("spatstat","Seurat"))'
RUN R -q -e 'if(!require(rmarkdown)) devtools::install_version("rmarkdown",version="2.5",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(tidyverse)) devtools::install_version("tidyverse",version="1.3.0",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(viridis)) devtools::install_version("viridis",version="0.5.1",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(hexbin)) devtools::install_version("hexbin",version="1.28.2",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(ggforce)) devtools::install_version("ggforce",version="0.3.3",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(RcppRoll)) devtools::install_version("RcppRoll",version="0.3.0",repos = "http://cran.r-project.org")'
RUN R -q -e 'if(!require(fastmatch)) devtools::install_version("fastmatch",version="1.1-3",repos = "http://cran.r-project.org")'
RUN R -q -e 'if(!require(BiocManager)) devtools::install_version("BiocManager",version="1.30.10",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(fgsea)) BiocManager::install("fgsea")'
RUN R -q -e 'if(!require(rtracklayer)) BiocManager::install("rtracklayer")'
RUN R -q -e 'if(!require(rjson)) devtools::install_version("rjson",version="0.2.20",repos = "https://cran.us.r-project.org")'
RUN R -q -e 'if(!require(ComplexHeatmap)) BiocManager::install("ComplexHeatmap")'

# # These should be already installed as dependencies of above packages
RUN R -q -e 'if(!require(dbplyr)) devtools::install_version("dbplyr",version="1.0.2",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(RColorBrewer)) devtools::install_version("RColorBrewer",version="1.1-2",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(glue)) devtools::install_version("glue",version="1.4.2",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(gridExtra)) devtools::install_version("gridExtra",version="2.3",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(ggrepel)) devtools::install_version("ggrepel",version="0.8.2",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(MASS)) devtools::install_version("MASS",version="7.3-51.6",repos = "http://cran.us.r-project.org")'
RUN R -q -e 'if(!require(data.table)) devtools::install_version("data.table",version="1.13.0",repos = "http://cran.us.r-project.org")'

RUN Rscript -e 'reticulate::py_config()'
RUN export RETICULATE_PYTHON=`which python`

ENV PATH /opt/conda/envs/VIP_py3.9_pandoc/bin:$PATH
RUN /bin/bash -c "source activate VIP_py3.9_pandoc"


ENV CELLXGENE_DATA=/cellxgene-data
ENV CELLXGENE_LOCATION=/opt/conda/envs/VIP_py3.9_pandoc/bin/cellxgene
ENV GATEWAY_ENABLE_ANNOTATIONS=true

CMD ["cellxgene-gateway"]
# ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "VIP_py3.9_pandoc", "cellxgene-gateway"]