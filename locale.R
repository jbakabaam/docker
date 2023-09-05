#!/usr/bin/env Rscript

readRenviron("/etc/default/locale")
lang <- Sys.getenv("LANG") # en_US.UTF-8

if (nchar(lang)) {
    Sys.setlocale("LC_ALL", lang)
}

Sys.getlocale("LC_ALL")
