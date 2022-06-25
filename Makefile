.PHONY: rely clean build test deploy milestone

rely:
	@npm ci

clean:
	@find . -type f -name *.log -delete
	@npm run clean

build: clean
	@npm run build

test: build
	@npm run server --debug

# AttrLink index needs to be generated when before deployment
deploy: build clean
	@git pull
	@git add -A && git commit -am "`date +'%Y%m%d%H%M%S'`" && git push -u origin master

milestone: deploy
	@git tag -a "`date +'%Y%m%d%H%M%S'`" -m "Release `date +'%Y%m%d%H%M%S'`"
	@git push origin --tags