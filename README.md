# README

## docker-composeを使ったrails + postgresql

## あらかじめ用意するもの

1. dockerfile
1. Gemfile
1. Gemfile.lock
1. docker-compose.yml

### 用意するdockerfile

```dockerfile
FROM ruby:2.4.5
RUN apt-get update -qq && apt-get install build-essential libpq-dev nodejs -y
RUN mkdir /app
WORKDIR /app
COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle install
COPY . /app
```

### 用意するGemfile

```gemfile
source 'https://rubygems.org'

gem 'rails', '~> 5.0.0.1'
```

### 用意するGemfile.lock

```gemfile
空欄。何も書かなくていい。
```

### 用意するdocker-compose.yml

サービス名: web
データベース名: db
ボリューム名: db-volumes

```docker-compose.yml
version: '3'
services:
  web:
    build: .  # 現在のディレクトリで
    command: bundle exec rails s -p 3000 -b '0.0.0.0'
    volumes:
      - .:/app  # 現在のディレクトリをコンテナ内のappディレクトリにマウント
    ports:
      - 3000:3000
    depends_on:
      - db
    tty: true
    stdin_open: true
  db:
    image: postgres
    volumes:
      - db-volumes:/var/lib/postgresql/data
volumes:
  db-volumes:
```

## ビルド手順

まずrails newでrailsプロジェクトを作成する
run webの「web」とはdocker-compose.ymlで名付けたサービス名を指す。
サービス「web」を起動して、コンテナ内でrailsプロジェクトを新規作成する。

```console
\$ docker-compose run web rails new . --force --database=postgresql
```

railsプロジェクトが作成されるとローカル環境にあるGemfileが上書きされる。
なぜなら、docker-compose.ymlのwebサービスでカレントディレクトリとコンテナ内の
appディレクトリが同期しているから(マウントしている)
そこで、再びdockefileを使って新しいGemfileに基づいてコンテナ内にrailsを書き込み、
イメージの内容を更新する。

```console
\$ docker-compose build
```

サービス「web」からデータベース「db」のpostgresqlを参照できるように
ファイルを書き換える(追記)。

```config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  host: db # 追記
  username: postgres # 追記
  password: # 追記
```

ここまでできたらコンテナを立ち上げる。

```console
\$ docker-compose up -d
```

さらにデータベースを作成する

```console
\$ docker-compose run web rails db:create
```

こんなログが流れてきたら成功！

```console
Created database 'app_development'
Created database 'app_test'
```

ブラウザから「localhost:3000」にアクセスして「Yay! You’re on Rails!」ページが表示されたらOK!
