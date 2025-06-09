version := $(shell date +"%Y-%m-%d").$(shell git rev-list --count HEAD)

.PHONY: tag
tag:
	git tag v$(version)

.PHONY: update
update:
	bash -cxe '                                                    \
		git fetch --progress origin master:master           && \
		git checkout -b $(version)                          && \
		git checkout -                                      && \
		git rebase "origin/master"                             \
	'
