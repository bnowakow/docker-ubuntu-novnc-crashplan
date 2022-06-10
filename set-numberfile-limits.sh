#!/bin/bash

number_of_files=1024;
#number_of_files=256;

cd /proc;

for file in `ls -1`; do
    prlimit --nofile=$number_of_files:$number_of_files --pid  $file;
    prlimit --nofile --pid  $file;
done;

prlimit --nofile=$number_of_files:$number_of_files;
prlimit --nofile;

for file in `ls -1 /proc/*/limits`; do echo -n $file; grep files $file; done
# while true; do echo ; echo; date; for file in `ls -1 /proc/*/limits`; do echo -n $file; grep files $file; done; sleep 3600; done

