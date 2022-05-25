# 必須サービスの各リソースの設定

## Upload Storage

### Upload

名称：'{project}upst{env}'
種類：ストレージアカウント

各設定
- 名前付き階層空間：無効
- コンテナ
  - upload001
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
    - Databricks用サブネット
    - セルフホステッド統合ランタイム用サブネット
    - パラメータで設定したIP
  - リソースインスタンス
    - 同サブスクリプションのSynapse Analytics
  - 信頼されたAzureアクセス：許可
- ライフサイクル管理
  - 90日間変更なしでCoolへ
- 構成
  - Blobパブリックアクセス：無効
  - ストレージアカウントキーによるアクセス：有効
  - - 既定のアクセス層：hot
  - レプリケーション：LRS
- 診断設定：すべてのログ(blobサービス)
  - LogAnalytics
  - Logging Blob storage
- RBAC
  - ストレージBlobデータ共同作成者
    - Synapse Workspace
    - Data Factory

## Data Lakes

### Laning/Raw

名称：{prefix}raw{env}
種類：ストレージアカウント

各設定
- 名前付き階層空間:有効
- コンテナ
  - 10-landing:フォーマット変換しないそのままのファイル保管を想定
  - 20-raw:DeltaLake化した未加工データの保管を想定
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
    - Databricks用サブネット
    - セルフホステッド統合ランタイム用サブネット
    - Azure ML Compute用サブネット
    - パラメータで設定したIP
  - リソースインスタンス
    - 同サブスクリプションのSynapse Analytics
  - 信頼されたAzureアクセス：許可
- ライフサイクル管理
  - 90日間変更なしでCoolへ
- 構成
  - Blobパブリックアクセス：無効
  - ストレージアカウントキーによるアクセス：有効（アカウントキーによるDatabricksマウント用のため※無効化してサービスプリンシパル利用を推奨）
  - 既定のアクセス層 : hot
  - レプリケーション：RA-GRS
- 診断設定：すべてのログ(blobサービス)
  - LogAnalytics
  - Logging Blob storage
- RBAC
  - ストレージBlobデータ共同作成者
    - Synapse Workspace
    - Data Factory

###　Enrich/Curated

名称：{prefix}encur{env}
種類：ストレージアカウント

各設定
- 名前付き階層空間:有効
- コンテナ
  - 30-enrich：型変換のみを行い利用OKな状態を保管する想定
  - 40-curate：ユースケースごとに変換した結果を保管する想定
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
    - Databricks用サブネット
    - セルフホステッド統合ランタイム用サブネット
    - Azure ML Compute用サブネット
    - パラメータで設定したIP
  - リソースインスタンス
    - 同サブスクリプションのSynapse Analytics
    - 同サブスクリプションのAzure ML
  - 信頼されたAzureアクセス：許可
- ライフサイクル管理
  - 90日間変更なしでCoolへ
- 構成
  - Blobパブリックアクセス：無効
  - ストレージアカウントキーによるアクセス：有効（アカウントキーによるDatabricksマウント用のため※無効化してサービスプリンシパル利用を推奨）
  - 既定のアクセス層 : hot
  - レプリケーション：ZRS（データレイク利用時の推奨値）
- 診断設定：すべてのログ(blobサービス)
  - LogAnalytics
  - Logging Blob storage
- RBAC
  - ストレージBlobデータ共同作成者
    - Synapse Workspace
    - Data Factory
    - Azure ML


## Network

### Vnet

名称：{prefix}-vnet-{env}
種類：仮想ネットワーク

各設定
- サブネット
  - PrivateEndpoint用サブネット：テンプレートでは利用しない。後から設定することを想定
  - Runtimeサブネット：セルフホステッド統合ランタイムおよびPower BI へのオンプレミスデータゲートウェイなどを設置する想定
    - サービスエンドポイント
      - SQL,Storage,Keyvault
  - Databricksサブネット（public/private）：Databricks クラスターが配置される
    - サービスエンドポイント
      - SQL,Storage,Keyvault
  - Azure ML Computing サブネット：AzureMLの計算環境が配置される
    - サービスエンドポイント
      - SQL,Storage,Keyvault

### Network Security Group（Runtime）

名称：{prefix}-runtime-nsg-{env}
種類：ネットワークセキュリティグループ

各設定
- 受信
  - RDP接続をパラメータで設定したIPから許可


### Network Security Group（Databricks）

名称：{prefix}-adb-nsg-{env}
種類：ネットワークセキュリティグループ

各設定
- [ネットワークセキュリティグループ規則](https://docs.microsoft.com/ja-jp/azure/databricks/administration-guide/cloud-configurations/azure/vnet-inject#network-security-group-rules-for-workspaces-created-after-january-13-2020)を参照
  - ※No-Public IPなので、一部インバウントを無効化

### Network Security Group（Azure ML）

名称：{prefix}-aml-nsg-{env}
種類：**ネットワークセキュリティグループ**

各設定
- [必要なパブリック インターネット アクセス](https://docs.microsoft.com/ja-jp/azure/machine-learning/how-to-access-azureml-behind-firewall?tabs=ipaddress%2Cpublic#required-public-internet-access)

## Logging

### Logging blob

名称：{prefix}logst{env}
種類：ストレージアカウント

各設定
- 名前付き階層空間：無効
- コンテナ
  - vulnerabilityscans：SQL脆弱性スキャン用
  - （その他自動生成）
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
  - 信頼されたAzureアクセス：許可
- ライフサイクル管理
  - 90日間変更なしでArchiveへ
- 構成
  - Blobパブリックアクセス：無効
  - ストレージアカウントキーによるアクセス：有効
  - - 既定のアクセス層：cool
  - レプリケーション：LRS
- RBAC
  - ストレージBlobデータ共同作成者
    - SQL Server
    - Synapse Workspace

### Log Analytics

名称：{prefix}-logws-{env}
種類：ログアナリティクスワークスペース

各設定：
- 保持期間：120日
- パブリックアクセス許可

## Data App Keyvault

### Key Vault

名称：{prefix}-appkv-{env}
種類：キーコンテナー

各設定：
- データ保護
  - 論理削除：有効
  - 消去保護：有効
  - 削除後の保持期間：90日
  - 
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
    - Databricks用サブネット
    - セルフホステッド統合ランタイム用サブネット
    - Azure ML Compute用サブネット
    - パラメータで設定したIP
  - 信頼されたAzureアクセス：許可
- RBAC
  - Secret Officer
    - Databricks Application ※Scopeに利用することを想定
  - Secret User
    - Synapse workspace
    - Data Factory