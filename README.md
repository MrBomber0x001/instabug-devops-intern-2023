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

* [x] Upgrade Go to 20
* [ ] Run the application locally without docker first!
* [x] Dockerfile
* [x] Docker compose

* [ ] Jenkins with Building Go project [build the app using dockerfile]
  * [x] Installing and building tools
  * [x] creating the docker hub credentials for docker inside jenkins
* [ ] install mysql on ubuntu
