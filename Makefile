all: upload clean


build:
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"

.PHONY: test
test: $(build)
	hexo generate
	hexo server -p 4321 --debug


.PHONY: deploy
deploy:
	npm run clean
	npm run build
	npm run deploy
	npm run clean


.PHONY: upload
upload:
	git pull
	git add -A
	git commit -am "upload or change some file"
	git push origin master:master

clean:
	find . -type f -name *.log -delete
	npm run clean
