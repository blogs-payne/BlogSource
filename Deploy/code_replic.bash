#!/usr/bin/env bash
git init
git checkout source
git add -A
git commit -m "upload"
git push origin source
git checkout master