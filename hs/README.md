# stack

## ビルドには、なぜ Stack であり、Cabal ではないか

* 原始 Cabal + Hackage の依存解決の困難とビルド再現性の不安定 → Stack + Stackage → Cabal も盛り返し、という経緯で、現 Cabal も Stack も、かつてほどの差は無いようだが、やはり先進性や柔軟性よりもビルド再現性を優先したいので、Stack を用いる
* 参考 — Haskellの環境構築2023 https://zenn.dev/mod_poppo/articles/haskell-setup-2023

## インストール手順

* Stack ではなく、GHCup で GHCup + Stack までを入れ、それ以降は Stack + Stackage で完結する
* `./ghcup` で透過的に実行
  * `GHCUP_PATH=true ./ghcup` で実パスを表示
  * `./ghcup upgrade` で自身をアップグレード
  * その他の subcmd は右記 — [User Guide - GHCup](https://www.haskell.org/ghcup/guide/)
* `./stack` で透過的に実行

## VSCode の HLS (Haskell Language Server) 設定

* まず、resolver (snapshot) の GHC バージョンを特定
  * https://raw.githubusercontent.com/commercialhaskell/stackage-snapshots/master/lts/22/33.yaml とか snapshot URL 見に行くと、
  * 以下のような指定がある
    ```
    resolver:
      compiler: ghc-9.6.6
    ```
  * 決して、ghcup でのインストールはしなくても良い。Stack のプロジェクトはプラグインが見るようで、GHC のバージョンは追っているようだよな？ 安心のために入れておいてもいい？
* とりあえず最新の HSL (たとえば 2.9.0.1) を GHCup で入れると、GHC のバージョンに相当する `haskell-language-server-9.6.6` 、あるいは `haskell-language-server-9.6.6~2.9.0.1` のような実行リンクがある。それを指定すると、あとは良い具合に ~/.stack/ 以下の該当する GHC を使うように見える