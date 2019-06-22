# これはなに？

GPIO 17 と 27 を入力として、入力があったら idobata にポストします。

また Phoenx を起動しているので、ページを開くとボタンが押された状態を WebSocket を使ってリアルタイムに表示します。

## 環境

Nerves, Phoenix を開発できる環境が必要です。

idobata へのポストには自作の [ExIdobata](https://github.com/mattsan/ex_idobata) を利用しています。

動作確認は Raspberry Pi Zero WH で行ないました。

| directory | description |
|---|---|
| firmware | Nerves プロジェクト。firmware をビルドします |
| buttons | GPIO の入力を idobata にポストするプロジェクト |
| beacon | 定期的（10 秒おき）に idobata にメッセージをポストするプロジェクト。システムが稼働していることを確認するために用意しています |
| web_monitor | GPIO の状態を web ブラウザで確認するための Phonenix プロジェクト |

## ビルド

### 環境変数

まず環境変数を設定します。

| variable | description |
|---|---|
| `MIX_TARGET` | ターゲットのデバイス。詳細は [Nerves のターゲットの説明](https://hexdocs.pm/nerves/targets.html) を参照してください。 |
| `IDOBATA_HOOK` | idobata のカスタムフックの URL |
| `NERVES_NETWORK_SSID` | 接続する WiFi の SSID |
| `NERVES_NETWORK_PSK` | 接続する WiFi のパスワード |

### Phoenix の assets のビルド

Phoenix の assets は mix コマンドのビルドの対象外なので、別途ビルドしておきます。

```sh
# Phoenix プロジェクトのディレクトリに移動します
$ cd web_monitor

# 依存するパッケージを取得します
$ mix deps.get

# assets のディレクトリに移動します
$ cd assets

# assets をビルドします
$ npm install && npm run deploy

# 元のディレクトリに戻ります
$ cd ../..
```

### firmware のビルド

buttons, beacon, web_monitor の 3 つのプロジェクトは firmware の依存関係に含まれているので、firmware をビルドすれば一緒にビルドされます。

```sh
# firmware プロジェクトのディレクトリに移動します
$ cd firmware

# 依存するパッケージを取得します
$ mix deps.get

# firmware をビルドします
$ mix firmware

# firmware を SD カードに書き込みます。コマンドを実行するマシンに SD カードを接続し、マシンに認識されてたらこのコマンドを実行してください
$ mix firmware.burn
```
