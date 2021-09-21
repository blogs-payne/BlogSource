all: upload clean
.PHONY: build test clean


build:
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"


test: $(build)
	hexo generate
	hexo server -p 4321 --debug


deploy:
	npm run clean
	npm run build
	npm run deploy
	npm run clean


upload:
	git pull
	git add -A
	git commit -am "upload or change some file"
	-git push origin master:master
	git push -u gitee

clean:
	find . -type f -name *.log -delete
	npm run clean
