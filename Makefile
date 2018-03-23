rendered/panubo-functions.sh: rendered functions/*
	cat functions/* > rendered/panubo-functions.sh

rendered:
	mkdir rendered

docker:
	docker build -t panubo/bash-container .
	docker run --rm -it -v $(shell pwd):/source panubo/bash-container
