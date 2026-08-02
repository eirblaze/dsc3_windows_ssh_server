# DSC v3 を使って、Windows PC 上に SSH サーバを構築する

このリポジトリは、Microsoft Desired State Configuration (DSC) v3 を使って、Windows PC 上に SSH サーバを構築・管理するための構成例をまとめるためのものです。

## 目的
- DSC v3 の宣言型構成を使って、SSH サーバの設定を再現可能にする
- Windows ホスト上での構成適用を簡単にする
- 将来的に、OpenSSH サーバやファイアウォール設定、サービス状態まで拡張できる土台を作る

## リポジトリ構成
- configs/: DSC 構成ファイル
- docs/: 設計メモ、運用メモ、参考リンク
- scripts/: PowerShell ヘルパースクリプト
- .github/: AI エージェント向け指示書や CI 設定

## DSC v3 のサンプルコマンド

### 1. 必要な構成をインストール

#### DSC のインストール

1. すでに MS Store 版 がある場合は、あらかじめアンインストールが必要です。
2. https://github.com/PowerShell/DSC から、最新の DSC をインストール
3. 上記の DSC (Appx 版 DSC v3) では `Microsoft.Windows/OptionalFeatureList` 等の、 DISM ベースのリソースがサポートされないため、先に OpenSSH.Server を以下のコマンドでインストールする必要がる。

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

DSC v3 ではサービス起動とファイアウォールのみ宣言的に管理する。

`Microsoft.Windows/OptionalFeatureList` をサポートする DSC の場合は、 `dsc resource install` (後述) が使用可能なので、 `configs/ssh-server.dsc.json` に以下を追加できる。

```json
{
  "resources": [
    {
      "resource": "Microsoft.Windows/OptionalFeatureList",
      "input": {
        "features": [
          {
            "featureName": "OpenSSH.Server",
            "state": "Installed"
          }
        ]
      }
    }
  ]
}
```

#### `dsc resource install` により、 DSC v3 Windows Resource Module を導入 ( DSC 完全版ビルドでのみ可能 )

```powershell
dsc resource install --module-name Microsoft.Windows --version latest
```

### 2. 構成の確認
```powershell
./scripts/resource.get.ps1
```

### 3. 構成の検証
```powershell
./scripts/resource.test.ps1
```

### 4. 構成の適用
```powershell
./scripts/resource.set.ps1
```

## 実行結果について補足

Windows Firewall はルールを内部的に正規化するため、
DSC v3 の desiredState と actualState に差分が出る場合があります。
これは仕様であり、構成は正しく適用されています。

## 今後の実装予定

1. [x] SSH サーバ機能の有効化
2. [x] ファイアウォール設定
3. [x] サービスの自動起動設定
5. [ ] SSH のハードニング（鍵認証・設定ファイル）を DSC v3 で宣言する
4. [ ] セキュリティ強化のための構成追加: ポートをウェルノウンポートから別のポートに切り替える。

## 注意事項

- `.env` 等の秘密情報や認証情報はリポジトリに直接コミットしない
- 構成はべき等性を意識して作成する
- 実際の運用前には、テスト環境での検証を行う

## 補助資料

OptionalFeatureList のスキーマ確認
```powershell
dsc resource schema --resource Microsoft.Windows/OptionalFeatureList
```

Service のスキーマ確認
```powershell
dsc resource schema --resource Microsoft.Windows/Service
```

FirewallRuleList のスキーマ確認
```powershell
dsc resource schema --resource Microsoft.Windows/FirewallRuleList
```
