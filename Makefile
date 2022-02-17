.PHONY: build test clean

rely:
	@npm ci

clean:
	@find . -type f -name *.log -delete
	@npm run clean

build: clean
	@npm run build

test: build
	@npm run server -p 4321 --debug

deploy: clean
	@git pull
	@git add -A
	@-git commit -am "upload or change some file"
	@-git push origin master:master

