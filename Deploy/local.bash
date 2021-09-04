#!/usr/bin/env bash
# update themes `next`
#git clone https://github.com/theme-next/hexo-theme-next themes/next

# local deployment
hexo clean && find . -type f -name *.log -delete
export NODE_OPTIONS="--max-old-space-size=8192"
hexo generate
hexo server -p 4321 --debug
