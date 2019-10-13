default: build_all push_all

USERNAME = e485b48b03c0

export = export "USER_NAME=e485b48b03c0"

login = docker login

build_all: build_ui build_post build_comment build_prometheus build_alert

build_ui:
		$(export) && cd ../src/ui/ && bash docker_build.sh && cd -

build_post:
		$(export) && cd ../src/post-py/ && bash docker_build.sh && cd -

build_comment:
		$(export) && cd ../src/comment/ && bash docker_build.sh && cd -

build_prometheus:
		docker build -t $(USERNAME)/prometheus -f ./prometheus/Dockerfile ./prometheus/

build_alert:
		docker build -t $(USERNAME)/alertmanager -f ./alertmanager/Dockerfile ./alertmanager/

push_all: push_ui push_post push_comment push_prometheus push_alert

push_ui:
		$(login)
		docker push $(USERNAME)/ui:logging

push_post:
		$(login)
		docker push $(USERNAME)/post:logging

push_comment:
		$(login)
		docker push $(USERNAME)/comment:logging

push_prometheus:
		$(login)
		docker push $(USERNAME)/prometheus:latest

push_alert:
		$(login)
		docker push $(USERNAME)/alertmanager:latest
