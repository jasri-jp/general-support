# 手元でサイトをビルドして表示する。
#   pixi run serve            … http://127.0.0.1:4000/general-support/ で表示（ファイルを編集すると自動で作り直す。出力先は一時フォルダ）
#   pixi run build            … リポジトリ直下の _site/ に出力するだけ
#   pixi run serve-lan        … 同じネットワークの他の PC からも見られるように起動（http://<この PC のホスト名>:4000/general-support/）
#   ruby tools/local_server.rb --port 4001 --host 0.0.0.0
#
# GitHub Pages と同じく、存在しないページには 404.html を返す
# （移行期間中は 404.html が現行サーバーの同じページへ転送する）。

$stdout.sync = true

# setup.rb で入れた gem を、依存関係の確認なしで読み込む
Gem.path.flat_map { |p| Dir[File.join(p, 'gems', '*', 'lib')] }.sort.each { |d| $LOAD_PATH.unshift d }
begin
  require 'jekyll'
  require 'webrick'
rescue LoadError => e
  abort "Jekyll が見つかりません（#{e.message}）。先に `pixi run setup` を実行してください。"
end

require 'tmpdir'
require 'digest'
require 'yaml'

ROOT = File.expand_path('..', __dir__)
SRC = File.join(ROOT, 'docs')   # サイト本体
# 公開時と同じパス（_config.yml の baseurl。例 /general-support）の下で表示する。/ は baseurl へ転送
BASE = (YAML.load_file(File.join(SRC, '_config.yml'))['baseurl'] || '').to_s.chomp('/')
# build はリポジトリ直下の _site/ に出力する。serve はこのフォルダの外（一時フォルダ）に出力する
# （このフォルダが Google ドライブの中にあっても、作り直すたびに同期が走らないようにするため）
DEST = if ARGV.include?('--build-only')
         File.join(ROOT, '_site')
       else
         File.join(Dir.tmpdir, "general-support_site_#{Digest::MD5.hexdigest(SRC)[0, 8]}")
       end
IGNORE = %r{\A(_site|\.git|\.pixi|\.jekyll-cache|\.sass-cache|vendor|public)(/|\z)|(\A|/)desktop\.ini\z}i
arg = ->(name, default) { (i = ARGV.index(name)) ? ARGV[i + 1] : default }
port = arg.('--port', 4000).to_i
# 127.0.0.1 = この PC からだけ見られる。0.0.0.0 = 同じネットワークの他の PC からも見られる（ファイアウォールの許可が必要）
host = arg.('--host', '127.0.0.1')

def build
  t = Time.now
  Jekyll::Commands::Build.process('source' => SRC, 'destination' => DEST, 'quiet' => true)
  puts format('built in %.1fs', Time.now - t)
rescue StandardError => e
  warn "build failed: #{e.class}: #{e.message}"
end

def snapshot
  Dir.glob('**/*', File::FNM_DOTMATCH, base: SRC)
     .reject { |f| f =~ IGNORE || File.directory?(File.join(SRC, f)) }
     .map { |f| [f, File.mtime(File.join(SRC, f)).to_f] }.sort
end

build
exit if ARGV.include?('--build-only')

# 変更の監視（2秒ごとに更新日時を比べる）
Thread.new do
  last = snapshot
  loop do
    sleep 2
    now = snapshot
    next if now == last
    last = now
    puts 'change detected, rebuilding...'
    build
  end
end

WEBrick::HTTPUtils::DefaultMimeTypes['html'] = 'text/html; charset=utf-8'
server = WEBrick::HTTPServer.new(Port: port, BindAddress: host,
                                 AccessLog: [], Logger: WEBrick::Log.new($stderr, WEBrick::Log::WARN))
files = WEBrick::HTTPServlet::FileHandler.get_instance(server, DEST)
not_found = lambda do |res|
  res.status = 404
  res['Content-Type'] = 'text/html; charset=utf-8'
  res.body = File.read(File.join(DEST, '404.html'), encoding: 'UTF-8')
end
server.mount_proc(BASE.empty? ? '/' : BASE) do |req, res|
  next res.set_redirect(WEBrick::HTTPStatus::Found, "#{BASE}/") if !BASE.empty? && req.path == BASE
  files.service(req, res)
rescue WEBrick::HTTPStatus::NotFound
  not_found.(res)
end
unless BASE.empty?
  server.mount_proc('/') do |req, res|
    req.path == '/' ? res.set_redirect(WEBrick::HTTPStatus::Found, "#{BASE}/") : not_found.(res)
  end
end
trap('INT') { server.shutdown }
if host == '127.0.0.1'
  puts "serving http://127.0.0.1:#{port}#{BASE}/  (Ctrl+C で終了)"
else
  require 'socket'
  require 'resolv'
  ip = Socket.ip_address_list.find { |a| a.ipv4? && !a.ipv4_loopback? && !a.ip_address.start_with?('169.254.') }&.ip_address
  name = (Resolv.getname(ip) rescue nil) if ip
  name ||= Socket.gethostname
  puts "serving http://#{name}:#{port}#{BASE}/  （他の PC から。IP では http://#{ip}:#{port}#{BASE}/ 、この PC では http://127.0.0.1:#{port}#{BASE}/ ）"
  puts '(Ctrl+C で終了)'
end
server.start
