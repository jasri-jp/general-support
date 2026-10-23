# Jekyll 3.10（GitHub Pages と同じ系統）と、ビルドに必要な gem を入れる。
#   pixi run setup
#
# Jekyll はライブ再読み込み用に C 拡張の gem（eventmachine など）にも依存しているが、
# ビルドと表示には使わないので、依存関係の自動解決はせずに必要なものだけを入れる。
# （C 拡張をビルドできない Windows の環境でも入るようにするため）
require 'rubygems/gem_runner'

GEMS = %w[
  jekyll:3.10.0
  liquid:4.0.4
  kramdown:2.5.1
  kramdown-parser-gfm:1.1.0
  rexml:3.4.4
  mercenary:0.3.6
  safe_yaml:1.0.5
  colorator:1.1.0
  pathutil:0.16.2
  forwardable-extended:2.6.0
  rouge:3.30.0
  i18n:1.15.2
  concurrent-ruby:1.3.8
  addressable:2.9.0
  public_suffix:7.0.5
  jekyll-sass-converter:1.5.2
  sass:3.7.4
  sass-listen:4.0.0
  webrick:1.9.2
  csv:3.3.6
  base64:0.3.0
  logger:1.7.0
].freeze

Gem::GemRunner.new.run(%w[install --no-document --ignore-dependencies --conservative] + GEMS)
puts 'setup done. Run: pixi run serve'
