#!/bin/bash

APPNAME="Itabe"
OUTDIR="build"

mkdir -p $OUTDIR

odin build src -out=${OUTDIR}/${APPNAME} -o:speed

