version := $(shell date +"%Y-%m-%d").$(shell git rev-list --count HEAD)
version_file := ./.version-suffix

define _release_script
	commit_to_fix=$(git log -1 --pretty=%H -- VERSION_FILE 2>/dev/null)
	printf -- "-%s" VERSION > VERSION_FILE
	git add -f VERSION_FILE
	if ! git diff --staged --quiet; then
		if [ -z "$commit_to_fix" ]; then
			git commit -m "update "VERSION_FILE
		else
			git commit --fixup="$commit_to_fix" --no-edit
			GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash $commit_to_fix~
		fi
	fi
	cat VERSION_FILE
	git tag $(printf "v%s" VERSION)
	git push tatikoma $(printf "v%s" VERSION)
endef
export release_script = $(value _release_script)

.PHONY: release
release:
	echo "$$release_script" | cpp -P -DVERSION_FILE="'$(version_file)'" -DVERSION="'$(version)'" | tee /dev/stderr | bash -xe

.PHONY: update
update:
	bash -cxe '                                                    \
		git fetch --progress origin master:master           && \
		git checkout -b $(version)                          && \
		git checkout -                                      && \
		git rebase --no-update-refs "origin/master"            \
	'
