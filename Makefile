.PHONY: build test clean

rely:
	@yarn install
	@yarn install --update-checksums

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


help:
	@echo "usage: make [options]"
	@echo "make build: Build It"
	@echo "make test: Start debugging"
	@echo "make deploy: Deployment that based on ssh"
	@echo "make upload:  Synchronization it"
	@echo "make clean:  clean it all log and built file"
