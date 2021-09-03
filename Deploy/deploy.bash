#!/usr/bin/env bash
# deployment
hexo clean && find . -type f -name *.log -delete
export NODE_OPTIONS="--max-old-space-size=8192"
npm run clean
npm run build
npm run deploy
npm run clean