#!/usr/bin/env bash
# update themes `next`
#git pull https://github.com/theme-next/hexo-theme-next themes/next

# local deployment
export NODE_OPTIONS="--max-old-space-size=32768"
hexo clean
hexo generate
hexo server --debug
hexo clean
