# 配布ファイル（Google ドライブ）の対応表 general-support-data/README.md を作り直す。
#   pixi run drive-table                       … ../../general-support-data/README.md に書く（共有ドライブ上の管理者用フォルダ application/general-support 用）
#   pixi run drive-table -- <README.md のパス>  … 指定したファイルに書く
#     例 pixi run drive-table -- "G:\共有ドライブ\support-web\general-support-data\README.md"
#   pixi run drive-table -- -                  … 画面に出すだけ
#
# 正本は docs/_data/drive.yml（現行のパス → ドライブのファイル ID）。
# 「リンク元ページ」は docs/ の中でそのパスを書いているページ。_data/*.yml に書いたものは、
# その yml を site.data.<名前> で使っているページをリンク元とする。
# 出力先と同じフォルダにファイルがあれば、drive.yml との食い違い（片方にしか無いファイル）も表示する。
require 'yaml'

ROOT = File.expand_path('..', __dir__)
DOCS = File.join(ROOT, 'docs')
DRIVE_YML = File.join(DOCS, '_data', 'drive.yml')
FOLDER_URL = 'https://drive.google.com/drive/folders/1tSBUHoIgqBzBV0BohBiZRSjQ4JHYkISH'

out = ARGV[0] || File.join(ROOT, '..', '..', 'general-support-data', 'README.md')
if out != '-' && !File.directory?(File.dirname(out))
  abort "出力先のフォルダがありません: #{File.dirname(out)}\n" \
        '共有ドライブの general-support-data/README.md のパスを指定してください（例 pixi run drive-table -- "G:\\共有ドライブ\\support-web\\general-support-data\\README.md"）'
end

drive = YAML.load_file(DRIVE_YML) || {}

# docs/ の中の各ファイルに書かれているパス（引用符の中、または yml の値）を集める
files = Dir.glob('**/*.{html,md,yml}', base: DOCS).reject { |f| f.start_with?('_site/') } - ['_data/drive.yml', '_includes/drive_url.html']
texts = files.to_h { |f| [f, File.read(File.join(DOCS, f), encoding: 'utf-8')] }
url_of = ->(f) { f.start_with?('_') ? f : "/#{f}" }
refs = Hash.new { |h, k| h[k] = [] }
texts.each do |f, s|
  # href="{% include drive_url.html path='/…' %}" のように入れ子になるので、引用符の種類ごとに別々に探す
  found = [/'([^'\n]+)'/, /"([^"\n]+)"/, /:[ \t]+(\/[^\n#]*?)[ \t]*$/].flat_map { |re| s.scan(re).flatten }
  sources = if f.start_with?('_data/')
              name = File.basename(f, '.yml')
              users = texts.select { |g, t| !g.start_with?('_') && t.include?("site.data.#{name}") }.keys
              users.empty? ? [f] : users.map(&url_of)
            else
              [url_of.(f)]
            end
  (found & drive.keys).each { |k| refs[k].concat(sources) }
end

esc = ->(s) { s.gsub('|', '\\|').gsub("\t", '<タブ>') }
rows = drive.keys.sort.map do |k|
  id = drive[k] && drive[k]['file_id'].to_s
  link = id.empty? ? '（ID 未記入。現行サーバーへリンク）' : "[開く](https://drive.google.com/file/d/#{id}/view)"
  pages = refs[k].uniq.sort.map { |p| "`#{esc.(p)}`" }.join(', ')
  "| `#{esc.(k)}` | #{link} | #{pages.empty? ? '（どのページからもリンクされていない）' : pages} |"
end
with_id = drive.values.count { |v| v && !v['file_id'].to_s.empty? }

md = <<~MD
  # general-support-data：Google ドライブに置く配布ファイル

  新サイト（`general-support`）から、Git ではなく Google ドライブで配布するファイル（PDF・zip・exe・xls など）。
  現行サーバー（support.spring8.or.jp）と同じパス構成で置いてある。

  - ドライブ上のフォルダ: #{FOLDER_URL}（共有ドライブ support-web/general-support-data）
  - ページからのリンクは `general-support/docs/_data/drive.yml`（現行のパス → ドライブのファイルID）で管理している。下の表と同じ内容。
  - **この表は手で編集しない。** `general-support` で `pixi run drive-table` を実行すると、drive.yml とページから作り直される（`tools/drive_table.rb`）。

  ## 運用

  - **差し替え**：ドライブで対象ファイルを右クリック →「ファイル情報」→「版を管理」→ 新しい版をアップロード。ID が変わらないので、サイト側の変更は不要。
    削除してから同じ名前でアップロードし直すと ID が変わり、リンクが切れる。
  - **追加**：このフォルダの同じパスに置き、ファイルの ID（「共有」→「リンクをコピー」の https://drive.google.com/file/d/<ID>/view の <ID>）を
    `general-support/docs/_data/drive.yml` に1件足す。ページからは `{% include drive_url.html path="/そのパス" %}` でリンクする。
    push したあと `pixi run drive-table` でこの表を作り直す。
  - **公開範囲**：サイトの利用者（外部）が開けるよう、このフォルダは「リンクを知っている全員が閲覧可」にしてある。
  - **注意**：論文などから現行URLのファイルに直接リンクされている場合、ドライブに移すとそのリンクは切れる。
    そうしたファイルは `general-support/docs/` の同じパスに置けば現行URLのまま残せる（その場合は drive.yml から外す）。
  - exe・zip などはダウンロード前にドライブのウイルススキャン確認画面が出ることがある。

  移行時（2026-10-23）に置いたファイルの ID は、ドライブの公開ページのファイル名と1件ずつ照合済み。

  ## 対応表

  | ファイル（general-support-data 内 ＝ 現行のパス） | ドライブ | リンク元ページ |
  |---|---|---|
  #{rows.join("\n")}

  合計 #{drive.size} ファイル（ID 記入済み #{with_id}）
MD

if out == '-'
  puts md
else
  File.write(out, md, mode: 'wb')
  puts "#{File.expand_path(out)} に書きました（#{drive.size} ファイル、ID 記入済み #{with_id}）"
end

# 確認用の表示（README には書かない）
unlinked = drive.keys.select { |k| refs[k].empty? }
warn "どのページからもリンクされていないファイル #{unlinked.size} 件: #{unlinked.first(5).join(', ')}#{unlinked.size > 5 ? ' …' : ''}" unless unlinked.empty?
missing = drive.keys.reject { |k| drive[k] && !drive[k]['file_id'].to_s.empty? }
warn "file_id が空のファイル #{missing.size} 件: #{missing.first(5).join(', ')}#{missing.size > 5 ? ' …' : ''}" unless missing.empty?
data_dir = out == '-' ? nil : File.dirname(out)
if data_dir
  local = Dir.glob('**/*', base: data_dir).select { |f| File.file?(File.join(data_dir, f)) }
             .reject { |f| f == File.basename(out) || File.basename(f).casecmp?('desktop.ini') }.map { |f| "/#{f}" }
  if local.size > drive.size / 2 # ドライブのフォルダを見られるときだけ比べる
    only_local = local - drive.keys
    only_yml = drive.keys - local
    warn "フォルダにあるが drive.yml に無いファイル #{only_local.size} 件: #{only_local.first(5).join(', ')}" unless only_local.empty?
    warn "drive.yml にあるがフォルダに無いファイル #{only_yml.size} 件: #{only_yml.first(5).join(', ')}" unless only_yml.empty?
  end
end
