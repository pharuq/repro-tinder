# Repro Tinder

指定したディレクトリ配下のファイルを解析して、ランダムなメソッドを表示します。(Rubyのみ対応)
Reproと言っているが特に関係はない。

## Getting started

```sh
# 対象となるディレクトリを環境変数SEARCH_PATHで指定する
$ SEARCH_PATH="/src/project/app"

$ bundle exec ruby app.rb

$ open http://localhost:4567

# クエリパラメータでclass_nameとmethod_nameを指定するとそれを開ける(method_nameは引数まで指定する)
$ open http://localhost:4567?class_name=Foo?method_name=baa(args)
```
