#!/bin/bash

Rscript -e 'devtools::install_github("leeshawn/MetaSKAT")'

while IFS=" " read -r package version; 
do 
  echo "install package $package:$version"
  Rscript -e "install.packages('"$package"', repos = 'https://cloud.r-project.org')";
done < "r-packages.txt"
