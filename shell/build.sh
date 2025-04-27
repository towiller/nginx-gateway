#!/bin/bash

cdir=$(cd `dirname $0`; cd ..; pwd)

echo $cdir

docker build -t towiller/gateway:v1.0.0 $cdir