# Redmineパッチ会

Redmine本体の改善をできる人を増やし、Redmineパッチ会を継続的に行っていけることを目的として、2020年7月から基本毎月オンライン開催しています。

基本は複数人のチームに分かれて、相談しながらパッチを書いています。  
(一人でもOK、今後参加者を中心にやり方が変わっていくかも)

## このリポジトリ

オープンソースのプロジェクト管理システム、[Redmine](https://redmine.org/projects/redmine)のフォークリポジトリです。  
このリポジトリでRedmineのバグ修正や機能改善を行い、Redmine本体に取り込んでもらうことでRedmineをより良くしていけるよう活動しています。

## Redmineパッチ会に参加したい

Redmineの改善に興味ある方であればどなたでも。  
プログラミングせずに画面の文言変更でもパッチは送れます。  
一緒に仕様を考えて、本家にチケットを作成するだけでもやれることはあります。 Ruby・Railsのプログラミング経験があると更に幅は広がります。

初参加の場合、見学からでもお気軽にどうぞ(^^

### 1. Connpassでイベントを公開しているので、参加申し込みをしてみましょう！

https://redmine-patch.connpass.com/  

### 2. 参加登録をしたら、オンラインのやりとり・当日の会場として利用しているDiscordに参加しよう！  

イベントに参加登録をした方にのみ参加用URLが確認可能です。  
参加の上で不安な点、わからない点があったらテキストチャンネルで気軽に相談してください👍

### 3. チーム開発に参加できる環境を整えよう！(プログラミング以外での参加の場合は不要)  

主に通話にDiscord、複数人でのコーディングにVisual Studio CodeのLive Share拡張を利用しています。  
**VSCodeのLive Shareでモブプロのように参加できるため、Redmineが動く開発環境がなくても参加できます。**

* [Visual Studio Code](https://code.visualstudio.com/)をインストール
* Visual Studio Codeを開いて、拡張機能 [Live Share](https://marketplace.visualstudio.com/items?itemName=MS-vsliveshare.vsliveshare)をインストール
* (ない人は)Githubのアカウントを作成

### 4. イベントの時間になったらDiscordを開いて、ボイスチャンネルに参加しよう！

(時間になったら他の参加者も参加しているはず)

## VSCode Remote ContainerによるRedmineの開発環境の作り方 / 機能

Redmineの開発環境を作るやり方のうちの一つです。開発環境がすでにある人はこの手順を使わなくても大丈夫です。

### 前提条件

* Docker Desktopを起動している
* Visual Studio Codeが利用できる

### 利用手順

* このリポジトリを手元にClone

```bash session
git clone --config=core.autocrlf=input https://github.com/redmine-patch-meetup/redmine-dev-mirror.git
cd ./redmine-dev-mirror
```

* 必要に応じて.devcontainer/.envを書き換える(portの衝突がなければデフォルトでも動きます)

```bash
# 開発中のRedmineに http://localhost:8000 でアクセス出来るようになる。8000を既に使っている場合は変える
APP_PORT=8000
# Seleniumのテストを実行するときに利用するポート。4444, 5900を既に使っている場合は変える
SELENIUM_PORT_1=4444
SELENIUM_PORT_2=5900
# Redmineから送信したメールを http://localhost:1080 で確認出来るようになる。1080を既に使っている場合は変える
MAILCATCHER_PORT=1080
# mysqlやsqlite3に変えても良い。mysqlの場合、.devcontainer/docker-compose.ymlのMySQL関連のコメントアウトを外す
RAILS_DB_ADAPTER=postgresql
# postgres、mysqlのホスト側への公開ポート。ホスト側で既に使っている場合は変える
POSTGRES_PORT=5433
MYSQL_PORT=3307
```

* VScodeに拡張機能[Remote-Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)をインストール

* VScodeで/your/path/redmine-dev-mirror を開く

<img width="1552" alt="フォルダを開く様子" src="https://user-images.githubusercontent.com/14245262/182572108-7f2cd55d-11eb-4a95-8a9f-e7ccb22b3f5d.png">

* 右下に出てくるポップアップのReopen in Containerを選択（出てこなかったらVSCodeのコマンドパレットからRemote Containers: Rebuild and Reopen in Containerを選択） => ビルドが始まるはず

<img width="1552" alt="Reopen in Containerボタン" src="https://user-images.githubusercontent.com/14245262/182571986-6557f3a3-8b04-43ca-8ad0-3fbfdab624fc.png">

* VSCodeの左側のバーが赤くなり、左側のファイルツリーも表示されたらコンテナ内に入れている状態

画面下のターミナルに"Press any key"と表示されるため、「キー入力を行い(ターミナルが閉じる)、メニューからターミナルを開く」か 「"Press any key"を放置したままターミナル右上のプラスを押す」 という流れでコマンドを入力できるようにする。

<img width="1552" alt="Press any keyと表示されている画面" src="https://user-images.githubusercontent.com/14245262/182572013-623e6df8-c3ed-4121-84bf-5d8a957dd276.png">
↓
<img width="1552" alt="コマンドを入力可能になった画面" src="https://user-images.githubusercontent.com/14245262/182572033-0a89e4e7-165d-4f6c-a656-5c5e2087a117.png">

* 画面下のターミナル内で
```bash
rails s -b 0.0.0.0
```
* 少し待つと、ブラウザから http://localhost:[.devcontainer/.envで指定したAPP_PORT] でRedmineにアクセスできるようになる。

<img width="1552" alt="Railsアプリケーションを起動できた画面" src="https://user-images.githubusercontent.com/14245262/182572087-5ea31d80-50ea-4af5-bbf1-64133a191b0b.png">

* テストの実行
```bash
bundle exec rake test RAILS_ENV=test
```

### おまけ

#### 1. VSCodeの拡張機能を増やしたい

.devcontainer/devcontainer.jsonのextensionsに拡張機能を追加し、VSCodeのコマンドパレットからRebuild and Reopen container

#### 2. Redmineから送信されるメールの内容をチェック

http://localhost:[.devcontainer/.envで指定したMAILCATCHER_PORT] でにアクセスするとメールキャッチャーを開ける

#### 3. Ruby3.0系以外のバージョンで動作検証やテストをしたい

.devcontainer/docker-compose.yml ファイルの `VARIANT: "3.0-bullseye"` の3.0-bulleseye 部分を利用したいバージョンに書き換えて、VSCodeのコマンドパレットからRebuild and Reopen container

#### 4. test/systemのテストを実行する場合

.devcontainer/docker-compose.yml内のchrome:の塊のコメントアウトを外し、VSCodeのコマンドパレットからRebuild and Reopen container

 selenium/standalone-chrome-debugイメージから持ってきたchromeを動かすためにCapybara周りで下のように設定を追加する。
 app == docker-composeでrailsアプリケーションが動いているところのサービス名
 chrome:4444 == docker-compose selenium/standalone-chrome-debugイメージのサービス名 + port

```diff
diff --git a/test/application_system_test_case.rb b/test/application_system_test_case.rb
index 1a1e0cb4a..fedbe7d15 100644
--- a/test/application_system_test_case.rb
+++ b/test/application_system_test_case.rb
@@ -43,13 +43,17 @@ class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
                     }
                   }
                 )
-
+  options[:browser] = :remote
+  Capybara.server_host = 'app'
+  Capybara.server_port = <.devcontainer/.envのAPP_PORT(デフォルト8000)に入れた値に書き換える>
   driven_by(
     :selenium, using: :chrome, screen_size: [1024, 900],
     options: options
   )
 
   setup do
+    Capybara.app_host = "http://#{Capybara.server_host}:#{Capybara.server_port}"
     # Allow defining a custom app host (useful when using a remote Selenium hub)
     if ENV['CAPYBARA_APP_HOST']
       Capybara.configure do |config|

```

```
 bundle exec rake test TEST=test/system RAILS_ENV=test
```

そのときホスト側で
```
open vnc://localhost:5900
```
を実行すると実際に動いているChromeの画面を見ることができる。 (パスワードを要求されたら `secret` と入れる)
