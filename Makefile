GIT_EMAIL := $(shell git config user.email)

rendered/panubo-functions.sh: rendered functions/*
	cat functions/* > rendered/panubo-functions.sh

rendered:
	mkdir rendered

rendered/panubo-functions.tar.gz: rendered/panubo-functions.sh
	tar -C rendered/ -zcf rendered/panubo-functions.tar.gz panubo-functions.sh

rendered/panubo-functions.tar.gz.asc: rendered/panubo-functions.tar.gz
	gpg2 --default-key $(GIT_EMAIL) --output rendered/panubo-functions.tar.gz.asc --armor --detach-sig rendered/panubo-functions.tar.gz

.PHONY: sign build-docker build-docker-alpine run-docker run-docker-alpine test-docker test-docker-alpine test shellcheck
sign: rendered/panubo-functions.tar.gz.asc

build-docker:
	docker build -f Dockerfile -t panubo/bash-container .

build-docker-alpine:
	docker build -f Dockerfile.alpine -t panubo/bash-container-alpine .

run-docker: build-docker
	docker run --rm -it -v $(shell pwd):/src --workdir /src --user user panubo/bash-container

run-docker-alpine: build-docker-alpine
	docker run --rm -it -v $(shell pwd):/src --workdir /src panubo/bash-container-alpine

test-docker:
	docker run --rm -i -v $(shell pwd):/src --workdir /src --user user panubo/bash-container make test shellcheck

test-docker-alpine:
	docker run --rm -i -v $(shell pwd):/src --workdir /src panubo/bash-container-alpine make test shellcheck

test:
	./test.sh

shellcheck:
	$(eval tmpdir := $(shell mktemp -d))
	cat functions/* > $(tmpdir)/panubo-functions.sh
	shellcheck $(tmpdir)/panubo-functions.sh
	rm -rf $(tmpdir)
