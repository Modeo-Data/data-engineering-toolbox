.PHONY: install
install:
	if [ -e "raycast-venv" ] ; then rm -rf raycast-venv ; fi
	python3 -m virtualenv raycast-venv
	( \
       source raycast-venv/bin/activate; \
       raycast-venv/bin/pip3 install -r requirements.txt; \
    )

.PHONY: format
format:
	source raycast-venv/bin/activate;
	raycast-venv/bin/pip3 install black
	black raycast

.PHONY: lint
lint:
	source raycast-venv/bin/activate;
	raycast-venv/bin/pip3 install flake8;
	flake8 raycast

.PHONY: pre-commit
pre-commit:
	source raycast-venv/bin/activate;
	raycast-venv/bin/pip3 install pre-commit ; \
    pre-commit run ;


.PHONY: clean
clean:
	rm -rf raycast-venv
