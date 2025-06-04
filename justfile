VERSION := "1.0.0"

build:
  make

format:
  terraform fmt -recursive

lint:
  shellcheck *.sh
  tflint

tag:
  git tag '{{VERSION}}' -m 'Release v{{VERSION}}'

push:
  git push origin --follow-tags

gh-release:
  bash ./scripts/release.sh '{{VERSION}}'

# Publish the release on GitHub
publish: tag push gh-release
