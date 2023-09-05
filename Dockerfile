FROM ubuntu:20.04

ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update -y
RUN apt-get install -y dirmngr gnupg apt-transport-https ca-certificates software-properties-common unzip build-essential libreadline-dev zlib1g-dev gfortran libx11-dev libxt-dev libbz2-dev liblzma-dev libpcre2-dev default-jdk libcairo2-dev curl libpng-dev libtiff-dev libssl-dev libcurl4-openssl-dev libxml2-dev gdebi-core wget openssh-server cmake git python3-pip libfontconfig1-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev python2 less gcc g++ libz-dev libpcre3-dev libopenblas-dev default-jre libboost-all-dev tabix

    
RUN ln -s /usr/bin/python2 /usr/local/bin/python

WORKDIR /tmp

# Install R 4.2.0
RUN wget https://cran.r-project.org/src/base/R-4/R-4.2.0.tar.gz && \
    tar -xf R-4.2.0.tar.gz && \
    cd R-4.2.0 && \
    ./configure --enable-R-shlib --without-x --with-cairo --with-libpng --with-blas="-lopenblas" && \
    mkdir -p /usr/local/lib/R/lib && \
    make && \
    make install

RUN R -e 'install.packages("devtools", repos="https://cloud.r-project.org")'

COPY install-packages.sh install-packages.sh
COPY r-packages.txt r-packages.txt

RUN chmod +x install-packages.sh && \
    ./install-packages.sh

# plink1.07
RUN wget https://zzz.bwh.harvard.edu/plink/dist/plink-1.07-x86_64.zip && \
    unzip plink-1.07-x86_64.zip && \
    mv plink-1.07-x86_64/plink /usr/local/bin

# plink1.9
RUN mkdir plink1.9 && \
    cd plink1.9 && \
    wget https://s3.amazonaws.com/plink1-assets/plink_linux_x86_64_20230116.zip && \
    unzip plink_linux_x86_64_20230116.zip && \
    mv plink /usr/local/bin/plink1.9

# plink2
RUN wget https://s3.amazonaws.com/plink2-assets/alpha4/plink2_linux_avx2_20230621.zip && \
    unzip plink2_linux_avx2_20230621.zip && \
    mv plink2 /usr/local/bin

# saige
RUN mkdir saige && \
    git clone --depth 1 -b master https://github.com/weizhouUMICH/SAIGE.git && \
    cd SAIGE && \
    /usr/bin/pip3 install cget && \
	/usr/local/bin/Rscript extdata/install_packages.R && \
    R CMD INSTALL . && \
	cp extdata/step1_fitNULLGLMM.R extdata/step2_SPAtests.R extdata/createSparseGRM.R /usr/local/bin/ && \
	chmod a+x /usr/local/bin/step1_fitNULLGLMM.R && \
	chmod a+x /usr/local/bin/step2_SPAtests.R && \
	chmod a+x /usr/local/bin/createSparseGRM.R


# qctool
RUN wget https://www.well.ox.ac.uk/~gav/resources/qctool_v2.2.0-CentOS_Linux7.8.2003-x86_64.tgz && \
    tar -xf qctool_v2.2.0-CentOS_Linux7.8.2003-x86_64.tgz && \
    mv ./qctool_v2.2.0-CentOS\ Linux7.8.2003-x86_64/qctool /usr/local/bin


#/storage/data/Tools

# bolt v2.4.1
RUN wget https://storage.googleapis.com/broad-alkesgroup-public/BOLT-LMM/downloads/BOLT-LMM_v2.4.1.tar.gz && \
    tar -xf BOLT-LMM_v2.4.1.tar.gz && \
    cd BOLT-LMM_v2.4.1 && \
    mv bolt /usr/local/bin && \
    mv lib/libiomp5.so /usr/lib


# Install rstudio-server
RUN wget https://download2.rstudio.org/server/focal/amd64/rstudio-server-2023.06.0-421-amd64.deb && \
    gdebi -n rstudio-server-2023.06.0-421-amd64.deb

# Conda
RUN wget https://repo.anaconda.com/archive/Anaconda3-2023.07-1-Linux-x86_64.sh && \
    bash Anaconda3-2023.07-1-Linux-x86_64.sh -b


# SSH
RUN mkdir /var/run/sshd && \
    echo 'root:basgenbio' | chpasswd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

RUN echo "\n\
  / __\ __ _ ___  __ _  ___ _ __ | |__ (_) ___     \n\
 /__\/// _` / __|/ _` |/ _ \ '_ \| '_ \| |/ _ \    \n\
/ \/  \ (_| \__ \ (_| |  __/ | | | |_) | | (_) |   \n\
\_____/\__,_|___/\__, |\___|_| |_|_.__/|_|\___/    \n\
                 |___/                             \n\
  ___                                              \n\
 ( _ )                                             \n\
 / _ \/\                                           \n\
| (_>  <                                           \n\
 \___/\/                                           \n\
                                                   \n\
   ___   __  __    __ _____  __   _____  ___    __ \n\
  / __\ /__\/ /   / //__   \/__\  \_   \/___\/\ \ \\n\
 / /   /_\ / /   / /   / /\/ \//   / /\//  //  \/ /\n\
/ /___//__/ /___/ /___/ / / _  \/\/ /_/ \_// /\  / \n\
\____/\__/\____/\____/\/  \/ \_/\____/\___/\_\ \/  \n\
" >> /etc/banner_buhm

RUN echo "Banner /etc/banner_buhm" >> /etc/ssh/sshd_config

# User
RUN groupadd basgen && \
    useradd -m -g basgen -s /bin/bash basgenbio && \
    echo 'basgenbio:basgenbio' | chpasswd

RUN apt-get install -y locales && \
    dpkg-reconfigure locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    export LC_ALL=en_US.UTF-8

WORKDIR /

COPY locale.R /locale.R
RUN chmod +x ./locale.R && \
    /usr/local/bin/Rscript locale.R

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
