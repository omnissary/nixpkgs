version := `printf '%s.%s' "$(date +%Y-%m-%d)" "$(git rev-list --count HEAD)"`
version_file := "./.version-suffix"

release:
    #!/usr/bin/env bash
    set -xe

    commit_to_fix="$(git log -1 --pretty=%H -- '{{ version_file }}' 2>/dev/null)"
    printf -- '-%s' '{{ version }}' > '{{ version_file }}'
    git add -f '{{ version_file }}'
    if ! git diff --staged --quiet; then
        if [[ -z "$commit_to_fix" ]]; then
            git commit -m 'update {{ version_file }}'
        else
            git commit --fixup="$commit_to_fix" --no-edit
            GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash "$commit_to_fix~"
        fi
    fi
    cat '{{ version_file }}'
    git tag 'v{{ version }}'
    git push tatikoma 'v{{ version }}'

update:
    #!/usr/bin/env bash
    set -xe

    git fetch --progress origin master:master
    git checkout -b '{{ version }}'
    git checkout -
    git rebase --no-update-refs origin/master
