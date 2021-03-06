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
***
## HW-14
## Работа с сетью в Docker

#### Null network driver

  - Для контейнера создается свой network namespace
  - У контейнера есть только loopback интерфейс
  ```
  lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
  ```
  - Сеть контейнера полностью изолирована
#### Host network driver

  - Контейнер использует network namespace хоста (поэтому выводы `docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig` и `docker-machine ssh docker-host ifconfig` не отличается)
```
  br-a7e1eee49780 Link encap:Ethernet  HWaddr 02:42:D6:A9:4C:4C  
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:d6ff:fea9:4c4c%32703/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:30 errors:0 dropped:0 overruns:0 frame:0
          TX packets:47 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:11924 (11.6 KiB)  TX bytes:11432 (11.1 KiB)

docker0   Link encap:Ethernet  HWaddr 02:42:FC:CC:74:9E  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:fcff:fecc:749e%32703/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:59711 errors:0 dropped:0 overruns:0 frame:0
          TX packets:73180 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:4609042 (4.3 MiB)  TX bytes:1238059852 (1.1 GiB)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:03  
          inet addr:10.132.0.3  Bcast:10.132.0.3  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:3%32703/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:576306 errors:0 dropped:0 overruns:0 frame:599
          TX packets:521496 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:2069009448 (1.9 GiB)  TX bytes:293093926 (279.5 MiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32703/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:932330 errors:0 dropped:0 overruns:0 frame:0
          TX packets:932330 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:126447265 (120.5 MiB)  TX bytes:126447265 (120.5 MiB)
```
  - Сеть не управляется самим Docker
  - Два сервиса в разных контейнерах не могут слушать один и тот же порт (поэтому 3 контейнера с nginx не смогли запустится, т.к. порт уже занят)
```
2019/09/17 20:19:06 [emerg] 1#1: bind() to 0.0.0.0:80 failed (98: Address already in use)
nginx: [emerg] bind() to 0.0.0.0:80 failed (98: Address already in use)
  CONTAINER ID        IMAGE                      COMMAND                  CREATED             STATUS                      PORTS               NAMES
e190445dfceb        nginx                      "nginx -g 'daemon of…"   20 seconds ago      Exited (1) 15 seconds ago                       quizzical_satoshi
15607f8d9d01        nginx                      "nginx -g 'daemon of…"   24 seconds ago      Exited (1) 20 seconds ago                       condescending_nightingale
a5a8dc381043        nginx                      "nginx -g 'daemon of…"   28 seconds ago      Exited (1) 23 seconds ago                       affectionate_mahavira
3df3f697a2df        nginx                      "nginx -g 'daemon of…"   33 seconds ago      Up 29 seconds                                   festive_montalcini
```
  - Производительность сети контейнера равна производительности сети хоста

```
sudo ln -s /var/run/docker/netns /var/run/netns
sudo ip netns
```

> ip netns exec <namespace> <command> - позволит выполнять команды в выбранном namespace

#### Bridge network driver
  - Назначается по умолчанию для контейнеров
  - Нельзя вручную назначать IP-адреса
  - Нет Service Discovery

## Docker-compose
Если базовое имя не задано, то используется название директории, в которой лежит файл docker-compose.yml.
Задать имя проекта можно с помощью переменной COMPOSE_PROJECT_NAME или указать имя во время поднятия композа `docker-compose -p my_project up -d`

> By default, Compose reads two files, a docker-compose.yml and an optional docker-compose.override.yml file. By convention, the docker-compose.yml contains your base configuration. The override file, as its name implies, can contain configuration overrides for existing services or entirely new services.
***

## HW-15
## Устройство Gitlab CI. Построение процесса непрерывной поставки

> Для запуска Gitlab CI мы будем использовать omnibus-установку. Основной плюс - можно быстро запустить сервис. Минусом такого типа установки является то, что такую инсталляцию тяжелее эксплуатировать и дорабатывать.

  - Ставим Docker `ansible-playbook -i inventory playbooks/packer_docker.yml`

```
mkdir -p /srv/gitlab/config /srv/gitlab/data /srv/gitlab/logs
cd /srv/gitlab/
touch docker-compose.yml
```
  - docker-compose.yml
```
  web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://<YOUR-VM-IP>'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

### Задание с *
  - build и deploy приложения для того чтобы .gitlab-ci.yml нормально отрабатывал пришлось изменить настройки внутри гитлаб-раннера в файле /etc/gitlab-runner/config.toml
```
privileged = true
volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
```
  - в гитлаб CI/CD -> Variables прописала значения для CI_REGISTRY_USER, CI_REGISTRY_PASSWORD

  - интеграция сo Slack - devops-team-otus.slack.com канал #lada_kalinkina
***

# HW-16. Введение в мониторинг. Системы мониторинга.

### Подготовка окружения
  - правила фаервола для Prometheus и Puma:
  ```
  gcloud compute firewall-rules create prometheus-default --allow tcp:9090
  gcloud compute firewall-rules create puma-default --allow tcp:9292
  ```
  - cоздание и настройка Docker хоста
  ```
  export GOOGLE_PROJECT=_ваш-проект_
  docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host
  eval $(docker-machine env docker-host)
  docker run --rm -p 9090:9090 -d --name prometheus  prom/prometheus
  ```
  `docker-machine ip docker-host` - узнать ip адрес

> Targets (цели) - представляют собой системы или процессы, за которыми следит Prometheus. Prometheus является pull системой, поэтому он постоянно делает HTTP запросы на имеющиеся у него адреса (endpoints).

> Вся конфигурация Prometheus, в отличие от многих других систем мониторинга, происходит через файлы конфигурации (prometheus.yml) и опции командной строки.

### Мониторинг состояния микросервисов

> Healthcheck-и представляют собой проверки того, что наш сервис здоров и работает в ожидаемом режиме. В нашем случае healthcheck выполняется внутри кода микросервиса и выполняет проверку того, что все сервисы, от которых зависит его работа, ему доступны.
Если требуемые для его работы сервисы здоровы, то healthcheck проверка возвращает status = 1, что соответсвует тому, что сам сервис здоров.
Если один из нужных ему сервисов нездоров или недоступен, то проверка вернет status = 0.

#### Exporters
  -  Программа, которая делает метрики доступными для сбора Prometheus
  -  Дает возможность конвертировать метрики в нужный для Prometheus формат
  -  Используется когда нельзя поменять код приложения
  -  Примеры: PostgreSQL, RabbitMQ, Nginx, Node exporter, cAdvisor

Ссылка на DockerHub репозиторий - docker.io/e485b48b03c0

## Задание со *

1) мониторинг MongoDB
  - использовался репозиторий https://github.com/percona/mongodb_exporter
  - на его основе собрала имидж
```
git clone git@github.com:percona/mongodb_exporter.git
cd mongodb_exporter
docker build -t $USER_NAME/mongodb_exporter .
```
  - добавила в prometheus.yml
```
- job_name: 'mongodb'
  static_configs:
    - targets:
      - 'mongodb-exporter:9216'
```
  - пересобрала образ прометеуса
  - добавила новый контейнер с экспортером
```
mongodb-exporter:
  image: ${USERNAME}/mongodb_exporter:latest
  environment:
    - MONGODB_URI='mongodb://mongo_db:27017'
  depends_on:
    - mongo_db
  networks:
    - back-net
    - front-net
```

2) Добавить мониторинг сервисов comment, post, ui с помощью blackbox экспортера.

#### Blackbox мониторинг
  - Мониторинг извне с точки зрения пользователя
  - Не видим, как работает система внутри
  - Примеры: проверка открытых портов, подсчет коннектов, наличие процесса

#### Whitebox мониторинг
  - Мониторинг на основе информации о внутренней работе системы
  - Примеры: метрики приложений (время запроса к БД, количество пользователей и т.д.)

 Реализация такая же как в предыдущем задании только вместо локльного билда имиджа скачиваем его с DockerHub.

 3) Makefile для автоматизации сборки и отправки имиджей в DockerHub
***

# HW-17. Мониторинг приложения и инфраструктуры.

### Подготовка окружения

```
$ export GOOGLE_PROJECT=_ваш-проект_
# Создать докер хост
docker-machine create --driver google \
    --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
    --google-machine-type n1-standard-1 \
    --google-zone europe-west1-b \
    docker-host
# Настроить докер клиент на удаленный докер демон
eval $(docker-machine env docker-host)
# Переключение на локальный докер
eval $(docker-machine env --unset)
$ docker-machine ip docker-host
```
### cAdvisor

> cAdvisor собирает информацию о ресурсах потребляемых контейнерами и характеристиках их работы.
```
cadvisor:
  image: google/cadvisor:v0.29.0
  volumes:
    - '/:/rootfs:ro'
    - '/var/run:/var/run:rw'
    - '/sys:/sys:ro'
    - '/var/lib/docker/:/var/lib/docker:ro'
  ports:
    - '8080:8080'
```

### Grafana

  - поддерживает версионирование дашбордов

### Мониторинг работы приложения
1) счетчик ui_request_count, который считает каждый приходящий HTTP-запрос 

### Alertmanager

> Alertmanager - дополнительный компонент для системы мониторинга Prometheus, который отвечает за первичную обработку алертов и дальнейшую отправку оповещений по заданному назначению.

  - Dockerfile
```
FROM prom/alertmanager:v0.14.0
ADD config.yml /etc/alertmanager/
```
  - config.yml
```
global:
  slack_api_url: 'https://hooks.slack.com/services/XXXXXXXXXXXXXXXXXXXXX'

route:
  receiver: 'slack-notifications'

receivers:
- name: 'slack-notifications'
  slack_configs:
  - channel: '#lada_kalinkina'
```
   - собираем образ `monitoring/alertmanager $ docker build -t $USER_NAME/alertmanager .`
   - добавим в докер-композ
```
  alertmanager:
    image: ${USERNAME}/alertmanager
    command:
      - '--config.file=/etc/alertmanager/config.yml'
    ports:
      - 9093:9093
```
   - alerts.yml определяет условия при которых должен срабатывать алерт и посылаться Alertmanager-у
   
### Task with *
1) билд alertmanager добавлен
2) Добавить сбор docker метрик в Prometheus 
Инструкция в [документации](https://docs.docker.com/config/thirdparty/prometheus/) 
в случае с docker-machine локалхост не работает - `Get http://localhost:9323/metrics: dial tcp 127.0.0.1:9323: getsockopt: connection refused`
нужно прописывать другой адрес и открывать данные докера в 0.0.0.0 что небезопасно
