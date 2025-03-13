# setup_for_mac

このリポジトリは、Nixおよびnix-darwinを使用してmacOS環境を効率的かつ再現可能な方法でセットアップするためのツールです。

## 概要

- **宣言的な設定**: Nixの宣言的なアプローチを使用して、macOSの設定やアプリケーションのインストールを管理
- **再現可能**: 異なるMacマシン間で同じ環境を簡単に複製
- **モジュール化**: 異なるホストマシンや設定要件に対応する柔軟なモジュールシステム
- **Homebrewとの統合**: nix-homebrewを通じてHomebrewパッケージも管理

## 前提条件

- macOS 11.0以降（Big Sur, Monterey, Ventura, Sonoma）
- 管理者権限
- インターネット接続

## セットアップ方法

1. リポジトリをクローン:
   ```bash
   git clone https://github.com/toyfer/setup_for_mac.git
   cd setup_for_mac
   ```

2. Nixをインストール:
   ```bash
   sh <(curl -L https://nixos.org/nix/install) --daemon
   ```

3. 新しいシェルセッションを開始するか、環境変数を読み込み:
   ```bash
   source ~/.nix-profile/etc/profile.d/nix.sh
   ```

4. Flakeを有効化して設定を適用:
   ```bash
   # 自分のホスト名を設定
   export HOST=$(hostname -s)
   export USERNAME=$(whoami)
   
   # 設定をビルドして適用
   nix build .#darwinConfigurations.${HOST}.system
   ./result/sw/bin/darwin-rebuild switch --flake .
   ```

## リポジトリ構造

```
.
├── flake.nix           # Nixプロジェクトのエントリーポイント
├── lib/                # 共通の関数を含むライブラリ
│   └── default.nix     # Darwin設定を生成する主要関数
├── modules/
│   ├── darwin/         # macOS固有の設定
│   │   ├── default.nix    # 基本設定
│   │   ├── homebrew.nix   # Homebrew管理
│   │   └── system-defaults.nix  # macOSシステム設定
│   └── home/           # ユーザー固有の設定(home-manager)
│       ├── default.nix    # ホームマネージャーの基本設定
│       ├── git.nix        # Gitの設定
│       ├── shell.nix      # シェル関連の設定
│       └── zsh.nix        # ZSH固有の設定
└── hosts/              # ホスト固有の設定
    └── MacminiM4/      # 特定のMac向けの設定
        └── default.nix
```

## 主な機能

- **システム設定の自動化**: Finder、Dock、キーボードなどのmacOS設定を自動的に構成
- **アプリケーション管理**: NixおよびHomebrewを通じて必要なアプリケーションをインストール
- **開発環境のセットアップ**: 開発ツールや設定ファイルの自動構成
- **ユーザー環境のカスタマイズ**: git、zsh、その他のユーザー固有の設定

## カスタマイズ方法

### 新しいMacの設定を追加

1. `hosts/`ディレクトリに新しいMac用のディレクトリを作成:
   ```bash
   mkdir -p hosts/YourMacName
   ```

2. 設定ファイルを作成:
   ```bash
   cp hosts/MacminiM4/default.nix hosts/YourMacName/
   ```

3. `hosts/YourMacName/default.nix`を編集して、特有の設定を追加

### パッケージの追加

- システムワイドなパッケージを追加する場合は`modules/darwin/default.nix`を編集
- ユーザー固有のパッケージを追加する場合は`modules/home/default.nix`を編集
- Homebrewパッケージを追加する場合は`modules/darwin/homebrew.nix`を編集

### ZSHの設定をカスタマイズ

`modules/home/zsh.nix`を編集して、ZSHの設定やプラグイン、テーマなどを変更できます。

## 更新方法

リポジトリの変更を取得し、設定を再適用します:

```bash
git pull
nix build .#darwinConfigurations.${HOST}.system
./result/sw/bin/darwin-rebuild switch --flake .
```

## トラブルシューティング

- **ビルドエラー**: `nix-collect-garbage -d`を実行してから再度試してください
- **設定が適用されない**: `sudo rm /etc/nix/nix.conf && sudo nixos-rebuild switch`を試してください
- **Homebrewの問題**: `brew doctor`を実行して問題を診断してください

## 詳細情報

Nixおよびこのリポジトリの構造についての詳細な情報は[nix_guide.md](./nix_guide.md)を参照してください。