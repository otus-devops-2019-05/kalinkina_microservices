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
  - ```
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
