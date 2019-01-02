VERSIONS := $(shell cat kube-versions)

schema = https://raw.githubusercontent.com/kubernetes/kubernetes/$@/api/openapi-spec/swagger.json
prefix = https://raw.githubusercontent.com/TODO------REPO-GOES-HERE/master/$@/_definitions.json
#TODO: repo arg

.PHONY: help kube-versions deploy clean $(VERSIONS)

help:
	@echo Supported targets: help kube-versions venv build-all deploy clean $(VERSIONS)

kube-versions:
	git ls-remote --refs https://github.com/kubernetes/kubernetes.git \
		| grep 'refs\/tags\/v' \
		| awk -F 'refs/tags/' '{print $$2}' \
		| grep -v 'alpha\|beta\|dev\|rc\|v0' \
		| sort --version-sort \
		> kube-versions

#TODO: test

venv:
	python3 -m venv venv
	. venv/bin/activate; \
		pip install git+https://github.com/jburianek/openapi2jsonschema.git@kube-properties

build-all: $(VERSIONS)

$(VERSIONS): venv
	@echo "Building JSON schema for Kubernetes version $@"
	mkdir -p output
	. venv/bin/activate; \
		openapi2jsonschema -o "output/$@-standalone-strict" --kubernetes --stand-alone --strict "$(schema)"; \
		echo openapi2jsonschema -o "output/$@-standalone" --kubernetes --stand-alone "$(schema)"; \
		echo openapi2jsonschema -o "output/$@-local" --kubernetes "$(schema)"; \
		echo openapi2jsonschema -o "output/$@" --kubernetes --prefix "$(prefix)" "$(schema)"
# TODO: remove above echos

deploy:
	git add output/
	git commit -m "Automated build"
	git push

clean:
	rm -rf venv/