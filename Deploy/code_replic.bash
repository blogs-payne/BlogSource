#!/usr/bin/env bash
git checkout source
git add -A
git commit -m "upload"
git push origin source
git checkout master