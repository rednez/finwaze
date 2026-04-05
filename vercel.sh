#!/bin/bash
if [[ $VERCEL_ENV == "production" ]] ; then
  ng build
else
  ng build --configuration staging
fi