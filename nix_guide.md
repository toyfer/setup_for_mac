# Nixの詳細ガイド

このガイドでは、Nixの基本概念から応用的な使い方まで、特にこのリポジトリでの用法に焦点を当てて解説します。

## 目次

1. [Nixの基本概念](#nixの基本概念)
2. [Nix言語の構文](#nix言語の構文)
3. [Nixパッケージマネージャ](#nixパッケージマネージャ)
4. [nix-darwin](#nix-darwin)
5. [home-manager](#home-manager)
6. [Nixフレーク](#nixフレーク)
7. [このリポジトリでのNixの使われ方](#このリポジトリでのnixの使われ方)
8. [応用例と設定カスタマイズ](#応用例と設定カスタマイズ)

## Nixの基本概念

Nixは以下の3つの側面を持っています：

1. **Nix言語**: 宣言的な設定言語
2. **Nixパッケージマネージャ**: パッケージの管理システム
3. **NixOS**: NixをベースとしたLinuxディストリビューション

Nixの哲学は「純粋性」と「再現性」に基づいており、以下の特徴があります：

- **宣言的**: 望ましい状態を記述し、システムがその状態になるよう変更を適用
- **アトミックな更新**: すべての変更が成功するか、全く変更されないか
- **ロールバック可能**: 以前の設定状態に簡単に戻せる
- **依存関係の分離**: 異なるバージョンの依存関係が互いに干渉しない

## Nix言語の構文

### 基本データ型

```nix
# 整数
let a = 42;

# 文字列（シングルクォートとダブルクォート）
let str1 = "hello ${name}";  # 変数展開可能
let str2 = 'hello $(name)';  # リテラル文字列

# パス
let path = ./relative/path;
let absPath = /absolute/path;

# リスト
let list = [ 1 2 3 4 ];

# 属性セット（辞書/マップ）
let attrs = {
  name = "value";
  nested = {
    attr = 123;
  };
};
```

### 変数と束縛

```nix
# let式で変数を束縛
let
  x = 1;
  y = 2;
in
  x + y  # 結果は3

# with式でスコープに属性を導入
let settings = { a = 1; b = 2; };
in with settings; a + b  # 結果は3
```

### 関数

Nixの関数は常に1つの引数を取るカリー化された形式です：

```nix
# 単一引数の関数
let increment = x: x + 1;

# 複数引数の関数（カリー化）
let add = a: b: a + b;
let result = add 1 2;  # 結果は3

# デフォルト引数付き関数
let greet = { name ? "world", prefix ? "Hello" }: "${prefix}, ${name}!";
let result = greet { name = "Nix"; };  # "Hello, Nix!"

# パターンマッチング
let getNameOrDefault = { name ? "default", ... }: name;
```

### 重要な演算子

```nix
# 属性アクセス
let attrs = { a.b.c = 1; };
let value = attrs.a.b.c;  # 1

# 属性存在確認
let hasAttr = attrs ? a;  # true

# デフォルト演算子
let value = args.name or "default";  # nameがない場合は"default"

# 更新演算子
let updated = attrs // { a = 2; };  # aを2に更新

# 条件式
let x = if 1 < 2 then "yes" else "no";  # "yes"
```

### インポート

```nix
# ファイルをインポート
let config = import ./config.nix;

# パラメータ付きインポート
let pkgs = import <nixpkgs> {};
let customConfig = import ./config.nix { inherit pkgs; };
```

### inherit キーワード

`inherit`は属性セットで変数を簡潔に取り込むために使います：

```nix
let
  x = 1;
  y = 2;
  attrs = {
    inherit x y;  # { x = 1; y = 2; } と同等
    z = 3;
  };
in
  attrs
```

## Nixパッケージマネージャ

### 主要コマンド

- `nix-env`: ユーザー環境の管理
  - `nix-env -i package`: パッケージをインストール
  - `nix-env -e package`: パッケージをアンインストール
  - `nix-env -q`: インストール済みパッケージを表示

- `nix-shell`: 一時的な開発環境
  - `nix-shell -p package`: パッケージを含む一時的なシェル

- `nix-build`: パッケージをビルド
  - `nix-build -A package`: 特定のパッケージをビルド

- `nix-collect-garbage`: 未使用パッケージを削除
  - `nix-collect-garbage -d`: 古い世代も削除

### チャンネルと参照

Nixでは、パッケージのコレクションを「チャンネル」として管理します：

```bash
# チャンネルを追加
nix-channel --add https://nixos.org/channels/nixpkgs-unstable
nix-channel --update

# チャンネルの参照
import <nixpkgs> {}
```

## nix-darwin

nix-darwinは、NixOSの概念をmacOSに拡張し、macOSシステム設定の宣言的管理を可能にします。

### 主な機能

- システム設定の管理
- パッケージのインストール
- サービスの管理
- ユーザー環境の設定

### 基本的な設定例

```nix
{ config, pkgs, ... }:
{
  # パッケージをインストール
  environment.systemPackages = with pkgs; [
    vim
    git
  ];
  
  # システム設定
  system.defaults.NSGlobalDomain.AppleKeyboardUIMode = 3;
  system.defaults.dock.autohide = true;
  
  # nix自体の設定
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
```

## home-manager

home-managerは、ユーザー固有の設定を宣言的に管理するためのツールです。

### 主な機能

- ドットファイルの管理
- ユーザー固有のパッケージのインストール
- シェルやエディタなどのアプリケーション設定

### 基本的な設定例

```nix
{ config, pkgs, ... }:
{
  # ユーザー固有のパッケージ
  home.packages = with pkgs; [
    ripgrep
    fd
    jq
  ];
  
  # プログラムの設定
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };
  
  # 環境変数
  home.sessionVariables = {
    EDITOR = "vim";
  };
}
```

## Nixフレーク

Nixフレークは、依存関係を明示的に宣言し、再現可能なビルドを実現する機能です。

### flake.nixの基本構造

```nix
{
  description = "My system configuration";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, home-manager, ... }: {
    darwinConfigurations.myMac = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
      ];
    };
  };
}
```

### フレークの主要コマンド

```bash
# フレークをビルド
nix build .#darwinConfigurations.myMac.system

# フレークを使って環境を更新
darwin-rebuild switch --flake .
```

## このリポジトリでのNixの使われ方

このリポジトリでは、Nixを以下のように使用しています：

### 1. システム設定の管理 (`modules/darwin/system-defaults.nix`)

```nix
{ config, lib, ... }:
{
  system.defaults = {
    finder = {
      AppleShowAllExtensions = true;
      FXPreferredViewStyle = "clmv";
    };
    
    NSGlobalDomain = {
      AppleKeyboardUIMode = 3;
      InitialKeyRepeat = 15;
      KeyRepeat = 2;
    };

    dock = {
      autohide = true;
      mru-spaces = false;
    };
  };
}
```

このファイルは、macOSの様々なシステム設定を宣言的に管理します。例えば：

- Finderの設定（拡張子の表示、表示スタイル）
- キーボード設定（キーリピート速度）
- Dockの設定（自動非表示、最近使用したスペース）

### 2. Homebrewの管理 (`modules/darwin/homebrew.nix`)

```nix
{ config, lib, inputs, username, ... }:
{
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = username;
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
    };
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    casks = [ 
      "firefox"
      "discord"
    ];
  };
}
```

このファイルは、Homebrewを通じてインストールされるアプリケーションを管理します：

- nix-homebrewの設定（Rosettaのサポート、ユーザー、タップ）
- インストールするHomebrewパッケージの指定
- casksを使った一般的なmacOSアプリケーションのインストール

### 3. 基本システム設定 (`modules/darwin/default.nix`)

```nix
{ config, pkgs, lib, hostname, username, ... }:
{
  imports = [
    ./homebrew.nix
    ./system-defaults.nix
  ];
  
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  nix.settings.experimental-features = "nix-command flakes";
  nix.extraOptions = ''
    extra-platforms = x86_64-darwin aarch64-darwin
  '';
  
  system.stateVersion = 5;
}
```

このファイルは、基本的なシステム設定を行います：

- 他のモジュールのインポート
- システム全体で利用可能なパッケージのインストール
- Nixの実験的機能の有効化
- プラットフォームのサポート設定

### 4. ユーザー環境の管理 (`modules/home/default.nix`)

```nix
{ config, pkgs, lib, username, ... }:
{
  imports = [
    ./git.nix
    ./shell.nix
  ];

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    gh
  ];

  home.stateVersion = "23.11";
}
```

このファイルは、ユーザー固有の環境設定を管理します：

- ユーザー固有のモジュールのインポート
- ユーザーのみが利用するパッケージのインストール
- ホームマネージャーのステートバージョン設定

### 5. Git設定 (`modules/home/git.nix`)

```nix
{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    userName = "yourname";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
```

このファイルは、Gitの個人設定を管理します：

- Gitの有効化
- ユーザー名とメールアドレスの設定
- デフォルトブランチの設定

### 6. ZSH設定 (`modules/home/zsh.nix`)

```nix
{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" "macos" ];
    };
  };
}
```

このファイルは、ZSHシェルの設定を行います：

- ZSHの有効化
- 自動提案や構文ハイライトの有効化
- Oh-My-ZSHの設定（テーマ、プラグイン）

### 7. システム構築ライブラリ関数 (`lib/default.nix`)

```nix
{ inputs }:

let
  inherit (inputs) nixpkgs nix-darwin home-manager nix-homebrew;
in rec {
  forAllSystems = nixpkgs.lib.genAttrs [ "aarch64-darwin" "x86_64-darwin" ];

  mkDarwinSystem = { hostname, system, username }: nix-darwin.lib.darwinSystem {
    inherit system;
    specialArgs = {
      inherit inputs hostname username system;
    };
    modules = [
      ../modules/darwin
      home-manager.darwinModules.home-manager
      {
        imports = [ ../hosts/${hostname} ];
        nixpkgs.hostPlatform = system;
        users.users.${username}.home = "/Users/${username}";
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${username} = import ../modules/home;
          extraSpecialArgs = {
            inherit username hostname;
          };
        };
      }
      nix-homebrew.darwinModules.nix-homebrew
    ];
  };
}
```

このファイルは、Darwinシステムの設定を生成するヘルパー関数を提供します：

- サポートするシステムのリスト
- Darwinシステムを構築するための関数（`mkDarwinSystem`）
- インポートするモジュールの指定
- ホスト固有の設定のマージ
- home-managerの統合

### 8. ホスト固有の設定 (`hosts/MacminiM4/default.nix`)

```nix
{ config, pkgs, lib, ... }:
{
  networking.hostName = "MacminiM4";
  
  environment.systemPackages = with pkgs; [
    # MacminiM4に特有のパッケージ
  ];
}
```

このファイルは、特定のMac固有の設定を管理します：

- ホスト名の設定
- そのホスト特有のパッケージや設定

## 応用例と設定カスタマイズ

### 1. 新しいホストの追加

新しいMacを設定する場合は、`hosts/`ディレクトリに新しいディレクトリを作成します：

```bash
mkdir -p hosts/NewMac
```

そして、設定ファイルを作成します：

```nix
{ config, pkgs, lib, ... }:
{
  networking.hostName = "NewMac";
  
  environment.systemPackages = with pkgs; [
    # 特有のパッケージ
  ];
  
  # この特定のMac向けのその他の設定
  system.defaults.dock.orientation = "left";
}
```

### 2. 新しいHomebrewアプリケーションの追加

`modules/darwin/homebrew.nix`にアプリケーションを追加します：

```nix
homebrew = {
  enable = true;
  onActivation.cleanup = "uninstall";
  brews = [
    "mas"  # Mac App Store CLI
  ];
  casks = [ 
    "firefox"
    "discord"
    "visual-studio-code"
    "docker"
    "iterm2"
  ];
};
```

### 3. ZSH設定のカスタマイズ

`modules/home/zsh.nix`でZSHの設定をカスタマイズします：

```nix
programs.zsh = {
  enable = true;
  enableAutosuggestions = true;
  enableSyntaxHighlighting = true;
  
  oh-my-zsh = {
    enable = true;
    theme = "agnoster";  # テーマを変更
    plugins = [ "git" "docker" "macos" "golang" "python" ];  # プラグインを追加
  };
  
  shellAliases = {
    ll = "ls -la";
    gs = "git status";
    gc = "git commit";
    gp = "git push";
  };
  
  initExtra = ''
    # 追加のZSH設定
    export PATH=$HOME/bin:$PATH
  '';
};
```

### 4. システムデフォルトの拡張

`modules/darwin/system-defaults.nix`でmacOSのシステムデフォルトをさらにカスタマイズします：

```nix
system.defaults = {
  finder = {
    AppleShowAllExtensions = true;
    FXPreferredViewStyle = "clmv";
    ShowPathbar = true;
    ShowStatusBar = true;
  };
  
  NSGlobalDomain = {
    AppleKeyboardUIMode = 3;
    InitialKeyRepeat = 15;
    KeyRepeat = 2;
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticDashSubstitutionEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticQuoteSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;
  };

  dock = {
    autohide = true;
    mru-spaces = false;
    minimize-to-application = true;
    show-recents = false;
    static-only = true;
    tilesize = 48;
  };
  
  trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
  };
};
```

## まとめ

このガイドでは、Nixの基本概念から具体的な使用法まで、特にこのリポジトリでのNixの用法に焦点を当てて説明しました。Nixの宣言的なアプローチは、macOS環境の設定を再現可能かつ柔軟な方法で管理できることが大きな利点です。

このリポジトリを拡張して、自分の環境に合わせてカスタマイズし、複数のMacに一貫したセットアップを適用できます。
