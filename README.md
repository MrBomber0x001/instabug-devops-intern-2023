# Wow Such Program

This program is very simple, it connects to a MySQL database based on the following env vars:

* MYSQL_HOST
* MYSQL_USER
* MYSQL_PASS
* MYSQL_PORT

And exposes itself on port 9090:

* On `/healthcheck` it returns an OK message,
* On GET it returns all recorded rows.
* On POST it creates a new row.
* On PATCH it updates the creation date of the row with the same ID as the one specified in query parameter `id`

## Tasks

* [ ] Run the application locally without docker first!

* [ ] Docker
  * [x] Dockerfile
  * [x] Docker Compose

* [x] Setup Jenkins
  * [x] Installing and building tools
  * [x] creating Github WebHook and Use Github Credentials in Jenkins
  * [x] creating the docker hub credentials for docker inside jenkins
  * [ ] Finish the pipeline
    * [ ] If error was in the build [report it]
    * [ ] unless, push it to dockerhub
    * [ ] use credentials
    * [ ] secure the pipeling with additional stage of security analysis like `Synk`

* [ ] Helm with K8S
* [ ] install mysql on ubuntu

### Bonus points

* [ ] Add autoscaling manifest for number of replicas.
* [ ] Add argocd app that points to helm manifests to apply gitops
concept.
* [ ] Secure your containers as much as you can.
  * [ ] Choosed lightweight and secure docker image
  * [ ] Run Code and Container security analysis using `Synk`
  * [ ] Added Additional stage in the Jenkins Pipeline before pushing to Docker repo
* [ ] Fix a bug in the code that would appear when you test the api

dckr_pat_HTDdCiQS7UY99yPnKO3_8MqeyW8
