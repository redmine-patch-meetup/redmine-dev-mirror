# redmine-dev-mirror用ファイル

# ログの保存箇所をvolumesの対象外にして同期による負かを軽くする
config.logger = Logger.new('../redmine.log', 2, 1000000)
