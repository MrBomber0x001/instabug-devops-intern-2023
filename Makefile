dockerBuild: 
	docker build -t go-instabug:v1 .
.PHONY: dockerBuild
dockerRun:
	docker run -it --name my-go-intern -p9090:9090 go-intern:v1
.PHONY: dockerRun
composeUp:
	cd compose && docker compose up --build
composeDown: 
	cd compose && docker compose down 
.PHONY: composeUp