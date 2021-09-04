all: deploy upload

.PHONY: test
test:
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"
	hexo generate
	hexo server -p 4321 --debug


.PHONY: deploy
deploy:
	hexo clean && find . -type f -name *.log -delete
	export NODE_OPTIONS="--max-old-space-size=8192"
	npm run clean
	npm run build
	npm run deploy
	npm run clean


.PHONY: deploy
upload:
	git add -A
	git commit -m "upload"
	git push origin source