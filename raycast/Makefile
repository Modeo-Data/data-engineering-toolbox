
.PHONY: install clean

install:
	if [ -e "raycast-venv" ] ; then rm -rf raycast-venv ; fi
	python3 -m virtualenv raycast-venv
	( \
       source raycast-venv/bin/activate; \
       raycast-venv/bin/pip3 install -r requirements.txt; \
    )
clean:
	rm -rf raycast-venv
