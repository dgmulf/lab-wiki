FROM ghcr.io/quarto-dev/quarto@sha256:966609c3b165de4a3f259527549c6f750cbe5298a1d35aac39313a37954578ff

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 python3-ipykernel python3-nbclient python3-nbformat python3-yaml \
        python3-numpy python3-pandas python3-matplotlib python3-scipy python3-seaborn \
        r-base-core r-cran-knitr r-cran-rmarkdown r-cran-ggplot2 \
        r-cran-dplyr r-cran-tidyr r-cran-readr r-cran-reticulate \
    && dpkg-query -W > /opt/renderer-packages.txt \
    && rm -rf /var/lib/apt/lists/*

ENV QUARTO_PYTHON=/usr/bin/python3 \
    RETICULATE_PYTHON=/usr/bin/python3 \
    MPLBACKEND=Agg \
    MPLCONFIGDIR=/tmp/matplotlib \
    XDG_CACHE_HOME=/tmp/.cache \
    JUPYTER_PLATFORM_DIRS=1 \
    OPENBLAS_NUM_THREADS=1 \
    OMP_NUM_THREADS=1
