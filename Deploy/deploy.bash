#!/usr/bin/env bash
# deployment
export NODE_OPTIONS="--max-old-space-size=32768"
npm run clean
npm run generate
npm run deploy
npm run clean