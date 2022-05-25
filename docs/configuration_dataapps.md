# 選択サービスの各リソースの設定

## Databricks

### Databricks

名称：'{project}-adb-{env}'
種類：データブリックスワークスペース

各設定

- パブリック IP を有効にしません：はい
- 診断設定：すべてのログ(blobサービス)
  - LogAnalytics
  - Logging Blob storage
- RBAC
  - 共同作成者： 
    - Synapse workspace
    - Data Factory
  

## Data Factory

### Data Factory

名称：'{project}-adf-{env}'
種類：データファクトリー

各設定

- ネットワークアクセス：パブリックエンドポイント
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage

- 統合ランタイム
  - Azure：マネージド仮想ネットワーク
  - セルフホステッド統合ランタイム：
- リンクサービス
  - Upload Blob storage
  - Landing/Raw Lake
  - Enrich/Curate Lake
  - Databricks
  - Machine Learning
  - SQL Database
  - Key Vault


#### Datafactoryセルフホステッド統合ランタイム用VM

名称：'{project}ir{env}'
種類：仮想マシン

各設定：
- スペック：Standard_A4_v2



## Machine Learning

### Machine Learning workspace

名称：'{project}-ml-{env}'
種類：機械学習

各設定：
- ネットワーク
  - パブリックネットワークアクセス：すべてのネットワーク
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage
- hbi:無効
- RBAC
  - 共同作成者
    - Synapse workspace
    - Data Factory

### ML用 Application Insights

名称：'{project}-mlai-{env}'
種類：Application Insights

各設定：既定

### ML用 blob Storage

名称：'{project}-mlst-{env}'
種類：ストレージアカウント

各設定
- 名前付き階層空間：無効
- コンテナ
  - （Azure MLにて自動生成）
- ネットワーク
  - 選択した仮想ネットワークと IP アドレスから有効
    - Databricks用サブネット
    - Azure ML Compute用サブネット
  - 信頼されたAzureアクセス：許可
- ライフサイクル管理
  - 90日間変更なしでCoolへ
- 構成
  - Blobパブリックアクセス：無効
  - ストレージアカウントキーによるアクセス：有効
  - - 既定のアクセス層：cool
  - レプリケーション：RA-GRS
- 診断設定：すべてのログ（blobサービス）
  - LogAnalytics
  - Logging Blob storage
- RBAC
  - ストレージBlobデータ共同作成者
    - Azure ML
    - Synapse workspace
    - Data Factory

各設定：既定

### ML用 Container Registry

名称：'{project}-mlcr-{env}'
種類：コンテナー レジストリ

各設定
- 名前付き階層空間：無効
- コンテナ
  - （Azure MLにて自動生成）
- ネットワーク
  - パブリックネットワークアクセス：すべてのネットワーク
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage

## Synasepe Analytics

### Synapse Workspace

名称：'{project}-syn-{env}'
種類：Synapse ワークスペース

各設定

- マネージド仮想ネットワーク：有効
- データ流出保護：パラメータにて制御
- Azure Active Directory:パラメータ内のセキュリティグループを適用
- AzureSQL監査：有効
- ネットワークアクセス
  - ワークスペースのエンドポイントへのパブリック ネットワーク アクセス:有効
  - ファイアウォール規則
    - Azure サービスおよびリソースに、このワークスペースへのアクセスを許可する：パラメータにて制御
    - パラメータに設定したIP
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage

- 統合ランタイム
  - Azure：マネージド仮想ネットワーク
  - セルフホステッド統合ランタイム：shir001

#### Spark Pool

名称：sparkpool001
種類：Spark Pool

各設定

- 構成
  - 自動スケーリング:有効
  - ノード サイズ：Small (4 仮想コア/32 GB)
  - セッション レベルのパッケージ:有効
  - エグゼキューターを動的に割り当てる：有効
  - ノード サイズ ファミリ：メモリ最適化
  - ノード数：3-12
  - 自動一時停止：15分
  - Apache Spark バージョン：3.2
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage 

#### 専用SQL Pool

名称：'dwh001'
種類：専用SQL Pool

各設定

#### Synapseセルフホステッド統合ランタイム用VM

名称：'{project}sir{env}'
種類：仮想マシン

各設定：
- スペック：Standard_A4_v2

## SQL

### SQL Server

名称：'{project}-sql-{env}'
種類：SQL Server

各設定

- Azure Active Directory:パラメータ内のセキュリティグループを適用
- パブリック ネットワーク アクセス
  - パブリック ネットワーク アクセス:選択したネットワーク
  - 仮想ネットワーク
    - Databricks用サブネット
    - セルフホステッド統合ランタイム用サブネット
    - Azure ML Compute用サブネット
  - ファイアウォール規則
    - パラメータで設定したIP
    - Azure サービスおよびリソースに、このワークスペースへのアクセスを許可する：パラメータにて制御
- ID : 
  - システムマネージドID：オン
- AzureSQL監査：有効

### SQL DB

名称：'{project}-sqldb-{env}'
種類：SQL データベース

各設定

- コンピューティングとストレージ
  - サービスレベル：汎用目的
  - コンピューティングレベル：サーバレス
  - コンピューティングハードウェア：
    - ハードウェア構成：第5世代
    - 最大仮想コア：4
    - 最小仮想コア：0.5
    - 自動一時停止：1時間
    - データの最大サイズ：250GB
  - データベースゾーン冗長性：いいえ
  - バックアップストレージ冗長性：geo冗長
- 診断設定：すべてのログ
  - LogAnalytics
  - Logging Blob storage 

