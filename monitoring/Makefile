default: build_all push_all

export = export USER_NAME=e485b48b03c0

login = $(export); docker login

build_all: build_ui build_post build_comment build_prometheus

build_ui:
		$(export)
		docker build -t $(USER_NAME)/ui -f ../src/ui/Dockerfile ../src/ui/

build_post:
		$(export)
		docker build -t $(USER_NAME)/post -f ../src/post-py/Dockerfile ../src/post-py/

build_comment:
		$(export)
		docker build -t $(USER_NAME)/comment -f ../src/comment/Dockerfile ../src/comment/

build_prometheus:
		$(export)
		docker build -t $(USER_NAME)/prometheus -f ./prometheus/Dockerfile ./prometheus/

push_all: push_ui push_post push_comment push_prometheus

push_ui:
		$(login)
		docker push $(USER_NAME)/ui:latest

push_post:
		$(login)
		docker push $(USER_NAME)/post:latest

push_comment:
		$(login)
		docker push $(USER_NAME)/comment:latest

push_prometheus:
		$(login)
		docker push $(USER_NAME)/prometheus:latest
