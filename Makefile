all: upload clean
.PHONY: build test clean

rely:
	yarn install --update-checksums


build: clean
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"


clean:
	-find . -type f -name *.log -delete
	@hexo clean


test:
	hexo clean && find . -type f -name *.log -delete
	hexo generate
	hexo server -p 4321 --debug


upload:
	@git pull
	@git add -A
	@-git commit -am "upload or change some file"
	@-git push origin master:master
	-#git push -u gitee


help:
	@echo "usage: make [options]"
	@echo "make Dependencies: Assembling an environment based on yarn"
	@echo "make build: Build It"
	@echo "make test: Start debugging"
	@echo "make deploy: Deployment that based on ssh"
	@echo "make upload:  Synchronization it"
	@echo "make clean:  clean it all log and built file"


