.PHONY: build test clean

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
deploy: clean build clean
	@git pull
	@git add -A
	@git commit -am "`date +'%Y%m%d%H%M%S'`"
	@git push -u origin master
	@#git tag -a "`date +'%Y%m%d%H%M%S'`" -m "Release `date +'%Y%m%d%H%M%S'`"
	@#git push origin --tags