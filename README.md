# info.jasri.jp/general-support（旧 support.spring8.or.jp）

JASRI 産学総合支援室のサイト（SPring-8 の産業利用支援）のソースです。
公開 URL は https://info.jasri.jp/general-support/ です。旧 URL の support.spring8.or.jp（現行サーバー）はそのまま動かし、まだ移していないページ・フォームはそちらへリンクします。
Jekyll で作っていて、GitHub の組織 jasri-jp のリポジトリ https://github.com/jasri-jp/general-support から GitHub Pages で公開します。
現行サイト（PHP）から、見た目と URL を変えずに移しています。

## フォルダ構成

```
README.md                     この説明
pixi.toml, pixi.lock          手元で立ち上げるための設定（pixi run setup / serve / serve-lan / build）
tools/                        立ち上げ用のスクリプト
Gemfile                       Ruby（Bundler）で立ち上げる場合の設定
docs/                         ← サイト本体。この中がそのまま https://info.jasri.jp/general-support/ になる
  _config.yml                 サイト設定（url, baseurl, legacy_url）
  _layouts/top.html           トップ系（Bootstrap）のレイアウト  ← 現行の header/footer の include に相当
  _layouts/legacy.html        BL系（旧デザイン）のレイアウト
  _layouts/redirect.html      旧URLから新URLへ転送するだけのページ
  _includes/top/              トップ系のヘッダー・フッター・読み込むCSS/JS
  _includes/legacy/           BL系の共通CSS・フッター・左メニュー（sidebar/）
  _includes/link.html         サイト内リンク（このサイトに無いページは現行サーバーへ）
  _includes/drive_url.html    Googleドライブのファイルへのリンク
  _data/news.yml              トップの Latest News
  _data/top_menu.yml          トップ系のメニュー
  _data/haxpes_samples.yml    HAXPES の試料一覧
  _data/drive.yml             Googleドライブに置くファイルの一覧（現行のパス → ドライブのファイルID）
  404.html                    未移行ページへのアクセスを現行サーバーへ転送（移行期間用）
  index.html, general.html …  各ページ（URL のパスと同じ場所に置く）
  assets/, BL/, report/, new/ 各ページと画像・CSS・JS（現行と同じパス）
```

サイト本体を `docs/` に分けているのは、GitHub Pages が公開元として「リポジトリの一番上」か「`docs/` フォルダ」しか選べないため。
`docs/` の中のパスが、`/general-support/` の下の URL のパスになる（例 `docs/BL/bl14b2/index.html` → `/general-support/BL/bl14b2/index.html`）。
リンクは相対パスか Jekyll の部品（`relative_url`・`link.html`）で書き、`/BL/...` のようにドメイン直下から書かない。

## よくある更新

- **トップのお知らせ**：`docs/index.html` 先頭の `notice:` を書き換える。
- **Latest News**：`docs/_data/news.yml` の先頭に1件追加する。
- **メニュー**：`docs/_data/top_menu.yml`（トップ系の全ページに反映される）。
- **HAXPES の試料追加**：アイコンを `docs/BL/bl46xu/haxpes/46haxpesdatabase/` に置き、`docs/_data/haxpes_samples.yml` に1行追加。PDFがあれば Googleドライブに置いて `docs/_data/drive.yml` に登録し、`pdf:` にそのパスを書く。
- **PDFの差し替え**：Googleドライブで「版を管理」→新しい版をアップロード（file_id が変わらないので、サイト側の変更は不要）。

## 配布ファイル（Google ドライブ）

PDF・zip・exe などの配布ファイルは、このリポジトリには入れず Google ドライブに置き、ファイル ID でリンクしています。

- `docs/_data/drive.yml` に「現行のパス → ドライブのファイル ID」を書く。
- ページからは `{% include drive_url.html path="/現行のパス" %}` でリンクする。
- `file_id` が空のファイルは、`docs/_config.yml` の `legacy_url`（現行サーバー）の同じパスにリンクする。
- ドライブ側でファイルを差し替えるときは「版を管理」で上書きする（ID が変わらないので、サイト側の変更は不要）。

## 手元でサイトを立ち上げる

### 方法1：pixi（おすすめ。Windows で動作確認済み）

Ruby を別にインストールする必要はない。pixi（https://pixi.sh）だけ入れておく。

```
git clone https://github.com/jasri-jp/general-support.git
cd general-support
pixi run setup
pixi run serve
```

- `pixi run setup` は最初に1回だけ。Ruby と Jekyll 3.10 などを入れる。入れる先はこのフォルダの `.pixi/`（`.gitignore` で除外しているので git には入らない。PC のほかの環境にも影響しない）。
- `pixi run serve` で http://127.0.0.1:4000/general-support/ に表示される（公開時と同じく `baseurl` の下。http://127.0.0.1:4000/ からも転送される）。ファイルを編集・保存すると数秒で自動的に作り直される。終了は Ctrl+C。
- ポートを変えるとき：`pixi run serve -- --port 4001`
- `pixi run build` は `_site/` に出力するだけ。
- 存在しないページには GitHub Pages と同じく `404.html` を返す。移行期間中は、それが現行サーバーの同じページへ転送する。

注意：

- **Windows では短いパスにクローンする**（例 `C:\work\general-support`）。Jekyll の中に深い階層のファイルがあり、パスが長いと
  Windows のパス長の上限（260文字）を超えて `pixi run setup` が失敗する。
- **Google ドライブなど同期されるフォルダの中でも、そのまま `pixi run setup` / `pixi run serve` で立ち上げられる**。
  Ruby などの環境（`.pixi/`、約2万ファイル・200MB）は最初の1回だけドライブに同期される。`serve` のビルド結果は一時フォルダに出力するので、編集のたびに同期が走ることはない。
- 正本の作業フォルダは共有ドライブ `support_web/general-support`（`.git` もこの中にあり、`git pull` / `commit` / `push` はここで行う）。
  ドライブの同期で `.git` が壊れないよう、次を守る。
  - 同じフォルダで、2台以上の PC から同時に git を操作しない（作業する PC を1台に決めるか、交代するときは同期が終わってから）。
  - 区切りごとにこまめに `git push` する。`.git` が壊れても、GitHub から `git clone` し直せば元に戻せる。
  - git がエラー（`index.lock` が残っている、オブジェクトが壊れている など）を出したら、ドライブの同期が終わるのを待ってからやり直す。
    直らなければ、ドライブの外に `git clone` し直して、未 push の変更だけ手で移す。

### 同じネットワークの他の PC から見られるようにする

`pixi run serve` はこの PC からしか見られない（127.0.0.1 で待ち受ける）。
ほかの人に同じネットワークの PC から見てもらうときは、代わりに次のコマンドで起動する。

```
pixi run serve-lan
```

起動すると、見てもらう URL が表示される（`http://<この PC のホスト名>:4000/general-support/` と、IP アドレスの URL）。
終了は Ctrl+C。見てもらう間だけ起動しておく。

最初の1回だけ、Windows のファイアウォールでポート 4000 への接続を許可する必要がある（管理者の権限が必要）。

- 初回の `pixi run serve-lan` で「Windows セキュリティの重要な警告」（ruby.exe の通信の許可）が出たら、
  **プライベート ネットワーク／ドメイン ネットワークだけ** にチェックして「アクセスを許可する」。公衆ネットワークは許可しない。
- 警告が出ない、または許可しても他の PC から見られない場合は、管理者として開いた PowerShell で次を実行する
  （`-RemoteAddress` は見てもらう PC のネットワークの範囲に合わせる。`LocalSubnet` は同じサブネットの PC だけ）。

```
New-NetFirewallRule -DisplayName "general-support preview (TCP 4000)" -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow -Profile Domain,Private -RemoteAddress LocalSubnet
```

- 使い終わったら、許可を外しておく。

```
Remove-NetFirewallRule -DisplayName "general-support preview (TCP 4000)"
```

注意：起動している間は、同じネットワークからこの PC の 4000 番に誰でもアクセスできる。
中身は公開予定の Web ページだけだが、見てもらう間だけ起動し、終わったら Ctrl+C で止める。

### 方法2：Ruby（Bundler）（未検証）

Ruby（Windows は RubyInstaller の DevKit 付き）が入っている場合。

```
bundle install
bundle exec jekyll serve --source docs
```

### 方法3：Docker（未検証）

```
docker run --rm -p 4000:4000 -v "$PWD/docs":/srv/jekyll jekyll/jekyll:3.8 jekyll serve --host 0.0.0.0
```


## 公開（GitHub Pages）

GitHub の組織 [jasri-jp](https://github.com/jasri-jp) の `general-support` リポジトリで公開する。

- jasri-jp の組織サイト（`jasri-jp.github.io` リポジトリ）に独自ドメイン `info.jasri.jp` を付ける。
  組織サイトに独自ドメインを付けると、組織のほかのリポジトリの GitHub Pages は自動的に `https://info.jasri.jp/<リポジトリ名>/` で公開される。
  このサイトは `https://info.jasri.jp/general-support/` になる（`docs/_config.yml` の `baseurl` が `/general-support`）。
- DNS の申請は `info.jasri.jp` の1回だけ。jasri-jp には、ほかの静的サイト（マニュアル・装置案内・イベントページなど、ログインのいらない公開情報）も
  1サイト＝1リポジトリで追加でき、`https://info.jasri.jp/<リポジトリ名>/` で公開される。組織のドメイン認証・2段階認証の設定は全サイトに効く。

### 試験公開（github.io）

1. `jasri-jp` に `general-support` リポジトリを作り、このフォルダの中身を push する。
2. Settings → Pages で「Deploy from a branch」→ `main` / `/docs` を選ぶ。
3. 組織サイトに独自ドメインを付ける前は `https://jasri-jp.github.io/general-support/` で表示される（`baseurl` はそのままでよい）。

### 本番（info.jasri.jp/general-support）

新しい URL で公開する。現行サーバー（support.spring8.or.jp）はそのまま動かし、旧 URL からの転送はしない。

1. 組織の Settings → Pages → Add a domain で `jasri.jp` を登録し、表示された TXT レコード（`_github-pages-challenge-jasri-jp.jasri.jp`）を DNS に追加して Verify する。
   登録しておくと、ほかのアカウントが `*.jasri.jp` の名前を GitHub Pages に設定できなくなる。
2. DNS 管理者に `info.jasri.jp` の CNAME を `jasri-jp.github.io` に設定してもらう。
3. 組織サイト（`jasri-jp.github.io` リポジトリ。サイトの一覧ページ）を公開し、Custom domain に `info.jasri.jp` を設定する。
   これで `https://jasri-jp.github.io/general-support/` は `https://info.jasri.jp/general-support/` に変わる（このリポジトリ側の設定は不要）。
4. 証明書が発行されたら、組織サイトで「Enforce HTTPS」を有効にする。
5. `docs/_config.yml` の `legacy_url` は現行サーバーのまま。まだ移していないフォームなどは現行サーバーへリンクされる。

全ページには `<link rel="canonical">` で新しい URL を書いている（レイアウトを使うページ）。検索結果は順に新しい URL に置き換わる。
