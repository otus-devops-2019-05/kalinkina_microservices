# kalinkina_microservices
#### kalinkina microservices repository
***

# HW-11. Введение в Docker

> Docker run каждый раз запускает новый контейнер. Если не указывать флаг --rm при запуске docker run, то после остановки контейнер вместе с содержимым остается на диске

  - `docker start <u_container_id>`
  - `docker attach <u_container_id>`
  - docker run = docker create + docker start + docker attach*
  - `docker commit <u_container_id> yourname/ubuntu-tmp-file` cоздает image из контейнера, контейнер при этом остается запущенным
  - kill сразу посылает SIGKILL
  - stop посылает SIGTERM, и через 10 секунд(настраивается) посылает SIGKILL

```
Usage:	docker system COMMAND
Manage Docker
Commands:
  df          Show docker disk usage
  events      Get real time events from the server
  info        Display system-wide information
  prune       Remove unused data
Run 'docker system COMMAND --help' for more information on a command.  
```
  - rm удаляет контейнер, можно добавить флаг -f, чтобы удалялся работающий container(будет послан sigkill)
  - rmi удаляет image, если от него не зависят запущенные контейнеры
  - `docker rm $(docker ps -a -q)` удалит все незапущенные контейнеры

#### Настройка gcloud
  - установить gloud
  - `gcloud init`
  - `gcloud auth application-default login` авторизация

#### Docker machine

> docker-machine - встроенный в докер инструмент для создания хостов и установки на них docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP и др.)

  - Команда создания - docker-machine create <имя>.
  - Имен может быть много, переключение между ними через eval $(docker-machine env <имя>).
  - Переключение на локальный докер eval $(docker-machine env --unset).
  - Удаление - docker-machine rm <имя>.


  - export GOOGLE_PROJECT=_ваш-проект_
  - 
  ```
  docker-machine create --driver google \
  --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
  --google-machine-type n1-standard-1 \
  --google-zone europe-west1-b \
  docker-host
  ```

  - `eval $(docker-machine env docker-host)`

  #### PID namespace

> Docker Hub - это облачный registry сервис от компании Docker. В него можно выгружать и загружать из него докер образы. Docker по умолчанию скачивает образы из докер хаба.

  - `docker diff reddit` показывает разницу в файлах между имиджом и контейнером

### Задача со *

  - packer_docker.yml для установки docker, docker.json для билда
  - terraform для создания инстанса и открытия фаервола
  - ansible deploy.yml для поднятия докер контейнера

# HW-12. Dockerfile

## Немного теории
  - PID namespace - отделяет образ видимости процессов друг от друга
  при запуске контейнера есть процесс, который создает первый процесс для дерева процессов внутри докера, от этого процесса с PID 1 создаются все дочерние процессы. Дочерние процессы ничего не знают о процессах, находящихся не в их дереве. 
  - net namespace - процессы в net namespace имеют собственные сетевые интерфейсы. Можно перемещать сетевые интерфейсы между нэймспэйсами. Сетевое пространство имен нельзя удалить при помощи системного вызова. Оно будет существовать пока его использует хотя бы один процесс. Мост docker0 обеспечивает общение всех контейнеров на хосте с ОС.
```
brctl show docker0
bridge name	bridge id		STP enabled	interfaces
docker0		8000.02428a3cd879	no		vethda5ab45
```
  - mnt namespace - создаем независимые файловые системы. Сначала дочерний процесс видит те же точки монтирования, что и родительский. Как только дочерний процесс перенес в отдельное пространство имен к нему можно примонтировать любую ФС. Точки монтирования могут быть приватными или доступными нескольким контейнерам. 
  - uts namespace - назначает хостнэйм и доменные имена. id контейнера - это хостнэйм.
  - IPC namespace - организует межпроцессорное взаимодействие, обеспечивают жоступ к shared memory

  `docker run --rm -ti tehbilly/htop` показывает процессы только внутри контейнера
  `docker run --rm --pid host -ti tehbilly/htop` показывает процессы хоста
  
## Dockerfile
  Сборка ui началась не с первого шага, потому что некоторые слои файловой системы уже были созданы в другом имидже и просто переиспользовались. 

> Сетевые алиасы могут быть использованы для сетевых соединений, как доменные имена.

`docker kill $(docker ps -q)` удаление контейнеров

#### Задание с *
  - для перезаписи значения переменных можно запускать контейнеры таким образом
  
```
docker run -d --network=reddit --network-alias=post_db_1 --network-alias=comment_db_1 mongo:latest
docker run -d --network=reddit --network-alias=post -e POST_DATABASE_HOST='post_db_1' <your-dockerhub-login>/post:1.0
docker run -d --network=reddit --network-alias=comment -e COMMENT_DATABASE_HOST='comment_db_1' <your-dockerhub-login>/comment:1.0
docker run -d --network=reddit -p 9292:9292 <your-dockerhub-login>/ui:1.0
```

  - уменьшение образа 
  2.0 - образ ubuntu
```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
/ui            2.0                 3090a19896d1        29 seconds ago      453MB
/ui            1.0                 0693301e3a2f        34 minutes ago      782MB
/comment       1.0                 9940b31c2e5a        38 minutes ago      780MB
/post          1.0                 ff93ebf20177        43 minutes ago      206MB
```
  3.0 - образ alpine
```
REPOSITORY                 TAG                 IMAGE ID            CREATED             SIZE
XXXXXXXXXXXX/ui            3.0                 5b4a06f51525        51 seconds ago      335MB
```
