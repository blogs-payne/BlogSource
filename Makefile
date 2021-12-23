all: upload clean
.PHONY: build test clean

rely:
	yarn install --update-checksums

clean:
	@find . -type f -name *.log -delete
	@hexo clean

build: clean
	export NODE_OPTIONS="--max-old-space-size=32768"
	npm run build

test: clean build
	hexo generate
	hexo server -p 4321 --debug

upload: clean
	@git pull
	@git add -A
	@-git commit -am "upload or change some file"
	@-git push origin master:master


help:
	@echo "usage: make [options]"
	@echo "make build: Build It"
	@echo "make test: Start debugging"
	@echo "make deploy: Deployment that based on ssh"
	@echo "make upload:  Synchronization it"
	@echo "make clean:  clean it all log and built file"


