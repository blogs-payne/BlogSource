all: deploy upload clean


build:
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"

.PHONY: test
test: $(build)
	hexo generate
	hexo server -p 4321 --debug


.PHONY: deploy
deploy: $(build)
	npm run clean
	npm run build
	npm run deploy
	npm run clean


.PHONY: deploy
upload:
	git add -A
	git commit -m "upload"
	git push origin source

clean:
	hexo clean && find . -type f -name *.log -delete
	npm run clean
