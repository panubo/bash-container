GIT_EMAIL := $(shell git config user.email)

rendered/panubo-functions.sh: rendered functions/*
	cat functions/* > rendered/panubo-functions.sh

rendered:
	mkdir rendered

rendered/panubo-functions.tar.gz: rendered/panubo-functions.sh
	tar -C rendered/ -zcf rendered/panubo-functions.tar.gz panubo-functions.sh

rendered/panubo-functions.tar.gz.asc: rendered/panubo-functions.tar.gz
	gpg2 --default-key $(GIT_EMAIL) --output rendered/panubo-functions.tar.gz.asc --armor --detach-sig rendered/panubo-functions.tar.gz

.PHONY: sign docker shellcheck test
sign: rendered/panubo-functions.tar.gz.asc

docker:
	docker build -t panubo/bash-container .
	docker run --rm -it -v $(shell pwd):/src --workdir /src panubo/bash-container

docker-alpine:
	docker build -f Dockerfile.alpine -t panubo/bash-container-alpine .
	docker run --rm -it -v $(shell pwd):/source panubo/bash-container-alpine

shellcheck: rendered/panubo-functions.sh
	shellcheck rendered/panubo-functions.sh

test:
	./test.sh
