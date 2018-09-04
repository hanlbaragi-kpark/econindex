## Docker + Django 개발환경

Docker 1.8 + Django ? + MySQL 5.7 으로 구성.

### Install Docker

생략 (먼저 설치하는 분이 적절한 링크를 추가해주세요.)

### Build Docker Images

아래와 같이 스크립트를 수행한다.
```sh
> ./run.sh build
```

이미지가 생성된 것을 확인한다.
```sh
> docker images
REPOSITORY                             TAG                 IMAGE ID            CREATED             SIZE
e500farmmanager_web                    latest              e9bbda3b7f85        19 hours ago        962MB
mysql                                  5.7                 43b029b6b640        7 days ago          372MB
python                                 latest              825141134528        2 weeks ago         923MB
phpmyadmin/phpmyadmin                  latest              93d0d7db5ce2        2 months ago        166MB
```

### Run Docker Containers

다음과 같이 Django 서비스에 필요한 모든 container 를 실행한다.
```sh
> ./run.sh start
```

아래와 같이 container 가 실행된 것을 확인한다.
```sh
> docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                     PORTS                               NAMES
608bf8af3494        e500farmmanager_web     "python manage.py ru…"   3 seconds ago       Exited (2) 2 seconds ago                                       e500farmmanager_web_1
2defc1d930e1        phpmyadmin/phpmyadmin   "/run.sh supervisord…"   4 seconds ago       Up 3 seconds               9000/tcp, 0.0.0.0:8080->80/tcp      e500farmmanager_phpmyadmin_1
8fa1c7656408        mysql:5.7               "docker-entrypoint.s…"   4 seconds ago       Up 3 seconds               0.0.0.0:3306->3306/tcp, 33060/tcp   django_db
```

Note)
```
 e500farmmanager_web 이 Django web service 용 container 인데, STATUS 가 Exited 인 것을 확인할 수 있다.
 이 것은 Django 에 project 를 생성한 후, MySQL 관련 설정을 해주어야 정상적으로 실행된다.
```

### Start Django Project

Django project 를 생성한다.
```sh
> ./run.sh startproject mysite
```

manage.py 와 mysite 가 생성된 것을 확인한다.
```sh
> ls
docker-compose.yml  Dockerfile  manage.py  mysite  README.md  run.sh
```

### Configure Django Project

mysite/settings.py 파일을 수정한다.

django-extentions 와 django-tables2 등을 사용하기 위해 `INSTALLED_APPS` 를 아래와 같이 수정한다.
```python
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_extensions',
    'django_tables2',
    'django_filters',
    'crispy_forms',
]
```

MySQL 을 사용할 것이므로 `DATABASES` 를 아래와 같이 수정한다.
아래에서 사용하는 환경 변수를은 docker-compose.yml 파일에서 정의하고 있다.
```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.environ.get('DJANGO_DB_NAME', 'mydb'),
        'USER': os.environ.get('DJANGO_DB_USERNAME', 'root'),
        'PASSWORD': os.environ.get('DJANGO_DB_PASSWORD', 'root123'),
        'HOST': os.environ.get('DJANGO_DB_HOST', 'db'),
        'PORT': os.environ.get('DJANGO_DB_PORT', '3306'),
    }
}
```

set language and time zone.
```python
LANGUAGE_CODE = 'ko-kr'
TIME_ZONE = 'Asia/Seoul'
```

add `STATIC_ROOT` after `STATIC_URL`
```python
STATIC_URL = '/static/'
STATIC_ROOT = os.path.join(BASE_DIR, 'static')
```

add below lines to connect from remote when debug mode.
```python
if DEBUG:
    ALLOWED_HOSTS = ['*']
```

이제 docker 를 재실행해 보자.
```sh
> ./run.sh stop
> ./run.sh start
```

docker container 들이 정상적으로 실행되었는지 확인한다.
```sh
> docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                               NAMES
a2391b4cb5a4        e500farmmanager_web     "python manage.py ru…"   3 seconds ago       Up 2 seconds        0.0.0.0:8000->8000/tcp              e500farmmanager_web_1
56952100c1e3        phpmyadmin/phpmyadmin   "/run.sh supervisord…"   3 seconds ago       Up 2 seconds        9000/tcp, 0.0.0.0:8080->80/tcp      e500farmmanager_phpmyadmin_1
294f462c6f3e        mysql:5.7               "docker-entrypoint.s…"   3 seconds ago       Up 2 seconds        0.0.0.0:3306->3306/tcp, 33060/tcp   django_db
```

각 서비스가 정상적으로 실행되는지 웹 페이지에 접속해서 확인해 본다.
1. phpmyadmin : http://localhost:8080 (root/root123)
2. Django : http://localhost:8000

### Django 명령 수행하기

Django 명령을 수행하려면 Django web server 가 실행되고 있는 docker container 에
shell 로 접속해야 한다.
```sh
> ./run.sh shell
```

이제 `python manage.py startapp myapp` 과 같은 Django 명령을 수행해서 app 을 만들어보자.
