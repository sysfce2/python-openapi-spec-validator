.EXPORT_ALL_VARIABLES:

PROJECT_NAME=openapi-spec-validator
PACKAGE_NAME=$(subst -,_,${PROJECT_NAME})
VERSION=`git describe --abbrev=0`

DOCKER_REGISTRY=pythonopenapi

PYTHONDONTWRITEBYTECODE=1

params:
	@echo "Project name: ${PROJECT_NAME}"
	@echo "Package name: ${PACKAGE_NAME}"
	@echo "Version: ${VERSION}"

dist-build:
	@python setup.py bdist_wheel

dist-cleanup:
	@rm -rf build dist ${PACKAGE_NAME}.egg-info

dist-upload:
	@twine upload dist/*.whl

test-python:
	@python setup.py test

test-cache-cleanup:
	@rm -rf .pytest_cache

reports-cleanup:
	@rm -rf reports

test-cleanup: test-cache-cleanup reports-cleanup

cleanup: dist-cleanup test-cleanup

docs-html:
	sphinx-build -b html docs docs/_build/html

docs-pagefind: docs-html
	@npx --yes pagefind --site docs/_build/html

docs-manifest:
	@cp docs/manifest.json docs/_build/html/manifest.json

docs-publish: docs-html docs-pagefind docs-manifest

docs-cleanup:
	@rm -rf docs/_build

docker-build:
	@docker build --no-cache --build-arg OPENAPI_SPEC_VALIDATOR_VERSION=${VERSION} -t ${PROJECT_NAME}:${VERSION} .

docker-tag:
	@docker tag ${PROJECT_NAME}:${VERSION} ${DOCKER_REGISTRY}/${PROJECT_NAME}:${VERSION}

docker-push:
	@docker push ${DOCKER_REGISTRY}/${PROJECT_NAME}:${VERSION}
