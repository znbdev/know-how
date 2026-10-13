Informatica CDC(Change Data Capture)（変更データキャプチャ）による更新履歴（変更履歴）生成の技術実装ガイド です。

Informatica CDC によるオブジェクト表更新および更新履歴生成の実装ガイド

本ドキュメントでは、Informatica を使用して「対象の業務オブジェクト表を更新（UPDATE）しつつ、同時にその変更履歴（更新履歴）を履歴表へ自動生成する」ための 2 つの実装アプローチについて解説します。

アプローチ 1：標準 ETL コンポーネントによるロジック CDC（追加コストなし）

追加のライセンス（PowerExchange など）を購入せず、標準のマッピング（Mapping）コンポーネントの組み合わせだけで、前日データと当日データの「差分」を比較して履歴を生成する手法です。

1. 業務シナリオ

• 処理概要: 日次で「顧客マスター（CUSTOMER_SRC）」の変更を検知し、最新状態を本番表（CUSTOMER_TRG）に反映すると同時に、すべての変更プロセスを履歴表（CUSTOMER_HIS）にインサートする。

2. マッピング（Mapping）構成案

データフローは以下のコンポーネント順で構成します。
text
[CUSTOMER_SRC] ──┐
├─► [Joiner] ─► [Expression] ─► [Router] ┬─► [Update Strategy] ─► [CUSTOMER_TRG (本番表)]
[CUSTOMER_TRG] ──┘                                         │
└─► [Expression] ────► [CUSTOMER_HIS (履歴表)]
请谨慎使用此类代码。

3. 各コンポーネントの設定詳細


① Joiner 変換（結合）

• 入力: 当日のソースデータ（SRC）と、前日のターゲット本番表（TRG）の両方を読み込みます。
• 結合条件: SRC.Cust_ID = TRG.Cust_ID
• 結合タイプ: Full Outer Join（完全外部結合）

② Expression 変換（状態判定ロジック）

結合されたデータに基づき、レコードが「新規」「更新」「削除」のどれに該当するかを判定するフラグ（v_FLAG）を作成します。
• 出力ポート（O_FLAG）の式:sql
IIF(ISNULL(TRG_Cust_ID), 'INSERT',
IIF(ISNULL(SRC_Cust_ID), 'DELETE',
IIF(SRC_Cust_Name != TRG_Cust_Name OR SRC_Cust_Status != TRG_Cust_Status, 'UPDATE', 'NO_CHANGE')
)
)
请谨慎使用此类代码。

③ Router 変換（条件分岐）

O_FLAG の値に応じて、データの出力先をグループ分けします。
• INSERT_GRP: O_FLAG = 'INSERT'
• UPDATE_GRP: O_FLAG = 'UPDATE'
• DELETE_GRP: O_FLAG = 'DELETE'

④ Target（ターゲット表）への書き込み制御

• 本番オブジェクト表（CUSTOMER_TRG）の流用流:
UPDATE_GRP のデータを Update Strategy 変換 に接続し、式に DD_UPDATE を指定して既存レコードを最新状態に上書き更新します。
• 履歴表（CUSTOMER_HIS）への流用流:
UPDATE_GRP のデータをそのまま履歴表の Target に接続します。履歴表側は更新（UPDATE）ではなく、常に新規追加（INSERT） として処理します。
• ※履歴表の手前の Expression で、sysdate を用いて CHANGE_TIME（変更日時） を自動付与します。

アプローチ 2：PowerExchange / IDMC ログベース CDC（リアルタイム・高性能）

Informatica の PowerExchange (PWX) オプション、またはクラウド版 IDMC (旧IICS) のレプリケーション機能を利用し、データベースのトランザクションログ（Oracle Redo Log, MySQL Binlog等）を直接キャプチャする高度な手法です。

1. 業務シナリオ

• 処理概要: 高頻度で更新される「注文テーブル（ORDERS）」の変更（Before/After）を秒単位で検知し、データウェアハウス上の監査・履歴表へリアルタイムに蓄積する。ソースデータベースへの検索クエリ（SELECT）が発生しないため、本番環境への負荷がほぼゼロになります。

2. Informatica 独自のメタデータ（メタフィールド）

CDC ソースを定義すると、Informatica は自動的に以下の DTL__CAPX から始まるシステム制御フィールドを付与します。これらを履歴表のマッピングにそのまま活用します。
• DTL__CAPXACTION: 変更の種類を示すフラグ（I: 挿入, U: 更新, D: 削除）。
• DTL__CAPXTIMESTAMP: データベースで実際に SQL が実行された正確なタイムスタンプ（ミリ秒単位）。
• DTL__CAPXUSER: 当該変更を実行したデータベースの操作ユーザー名。

3. IDMC（クラウド）でのデータ摂入タスク（Database Ingestion）設定例

UI 上でノンコーディング（GUI マウス操作のみ）で設定が完了します。
1. Task Type の選択: Database Ingestion Task を新規作成。
2. ロードタイプの指定: Load Type を Initial and Incremental Volumes（初回全量 + 以降リアルタイム増量） に設定。
3. 接続元の設定（Source）: 対象のソースデータベースとテーブルを選択し、Log-Based Approach（ログベース） を有効化。
4. 接続先の設定（Target）: 履歴を蓄積するデータウェアハウス（Snowflake / BigQuery等）を選択し、プロパティで "Keep Ingestion History"（摂入履歴を保持） にチェックを入れます。

4. 実行結果（履歴表に生成されるデータのイメージ）

ソース側で以下の更新 SQL が実行された場合：
sql
UPDATE ORDERS SET STATUS = 'SHIPPED' WHERE ORDER_ID = 1001;
请谨慎使用此类代码。
ターゲットの履歴表には、何も開発コードを書くことなく、以下のような履歴レコードが自動的にインサート（追加）されます。

ORDER_ID	STATUS	DTL__CAPXACTION	DTL__CAPXTIMESTAMP	DTL__CAPXUSER
1001	SHIPPED	U	2026-10-13 21:00:00.123	APP_SHOP_USER


2つのアプローチの比較


評価項目	アプローチ 1：ロジック CDC (標準)	アプローチ 2：ログベース CDC (高級)
ライセンス費用	追加費用なし（標準機能）	要追加ライセンス（PWX / CDIR）
ソースへの負荷	高い（毎回全件または大量データを読み込むため）	ほぼゼロ（ログファイルを直接読み取るため）
リアルタイム性	バッチ処理（日次・時間次）向き	リアルタイム・ニアリアルタイム向き
開発の複雑さ	マッピング内で比較ロジックの構築が必要	初期設定のみで、マッピング開発は不要

こちらのドキュメントの内容について：
• 特定のデータベース（Oracle、SQL Server、MySQL など）に特化したPost-SQL やトリガーの具体例も追加で必要でしょうか？
• もし気になる点や、さらに深掘りしたいコンポーネントの設定があればお知らせください。

---

針對您提到的 Oracle から PostgreSQL へのデータベース移行 场景，在 Informatica 環境下實現「更新 PostgreSQL 標的表的同時，生成更新履歷」有其特定的注意事項和最佳實踐。Oracle 與 PostgreSQL 的語法和數據類型存在差異，因此在設計時需要特別注意。
以下為您單獨整理一份針對 Oracle to PostgreSQL 的技術實踐與更新履歷生成的 Markdown 文檔（日文版）：

Informatica 技術ガイド：Oracle から PostgreSQL への移行および更新履歴生成

本ドキュメントでは、ソースデータベースが Oracle、ターゲットデータベースが PostgreSQL の環境において、Informatica を用いて本番オブジェクト表を更新しつつ、変更履歴（監査ログ）を自動生成するための具体的な実装方法について解説します。

1. データベース特性の違いによる注意点（Oracle vs PostgreSQL）

Informatica を介して Oracle から PostgreSQL へデータを連携・更新する際、以下の違いをマッピング（Mapping）設計に反映させる必要があります。
• 大文字・小文字の扱い:
• Oracle はオブジェクト名（表名、列名）をデフォルトで大文字として扱います。
• PostgreSQL はデフォルトで小文字として扱います。Informatica の Target 定義や SQL 識別子（Identifier）のクォーテーション設定に注意してください。
• データ型のマッピング:
• Oracle の DATE (時刻含む) または TIMESTAMP ──► PostgreSQL の TIMESTAMP または TIMESTAMPTZ（タイムゾーン付き）。
• Oracle の VARCHAR2 ──► PostgreSQL の VARCHAR または TEXT。
• システム日時の取得:
• Oracle の SYSDATE ──► PostgreSQL の CURRENT_TIMESTAMP または now()（Informatica 内では共通して sysdate 関数が使用可能）。

2. 実装パターン 1：標準 ETL（マッピング）によるダブル・ライト（推奨）

ソース（Oracle）から変更を検知し、PostgreSQL の本番オブジェクト表（更新）と履歴表（挿入）へ同時に書き込む最も確実な方法です。

マッピングの論理フロー

1. Source Qualifier (Oracle): Oracle のソース表からデータを抽出。
2. Lookup 変換 (PostgreSQL): ターゲットである PostgreSQL の現在データ（主キーの一致）を検索し、既存の値を取得。
3. Expression 変換 (比較ロジック):
   • Oracle の値と PostgreSQL の値を比較し、変更の有無（UPDATE かどうか）を判定。
   • 例（変更判定ポート v_IS_UPDATED）:sql
   IIF(NOT ISNULL(lkp_PG_CUST_ID) AND (ora_CUST_NAME != lkp_PG_CUST_NAME), 1, 0)
   请谨慎使用此类代码。
4. Router 変換 (分岐): v_IS_UPDATED = 1（更新対象）のデータを2つのルートに分岐。
5. ターゲットへの書き込み (PostgreSQL):
   • ルート A（本番表）: Update Strategy 変換 を挟み、DD_UPDATE で PostgreSQL の本番表を更新。
   • ルート B（履歴表）: Update Strategy は使用せず、そのまま履歴表へ INSERT（追加）。Expression で sysdate を渡し、変更日時として記録。

3. 実装パターン 2：PostgreSQL のトリガー（Trigger）を利用した履歴自動生成

Informatica 側のマッピングをシンプルに保ち（本番表への UPSERT のみ）、履歴の生成ロジックを PostgreSQL 側に完全委ねる手法です。Informatica のパフォーマンス向上に寄与します。

① PostgreSQL 側に履歴表を作成

sql
-- 本番オブジェクト表（例）
CREATE TABLE t_customer (
cust_id INT PRIMARY KEY,
cust_name VARCHAR(100),
updated_at TIMESTAMP
);

-- 更新履歴表
CREATE TABLE t_customer_history (
history_id SERIAL PRIMARY KEY,
cust_id INT,
old_name VARCHAR(100),
new_name VARCHAR(100),
action_type VARCHAR(10),
changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
请谨慎使用此类代码。

② PostgreSQL 側でトリガー関数とトリガーを定義

Informatica が t_customer に対して UPDATE を実行した瞬間に、この関数が自動的に起動し、新旧の値を比較して履歴表へ挿入します。
sql
-- 1. トリガー関数の作成
CREATE OR REPLACE FUNCTION log_customer_changes()
RETURNS TRIGGER AS $$
BEGIN
-- 値に変更があった場合のみ履歴を記録
IF (OLD.cust_name IS DISTINCT FROM NEW.cust_name) THEN
INSERT INTO t_customer_history (cust_id, old_name, new_name, action_type)
VALUES (OLD.cust_id, OLD.cust_name, NEW.cust_name, 'UPDATE');
END IF;
RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. トリガーのバインド
CREATE TRIGGER trg_customer_audit
AFTER UPDATE ON t_customer
FOR EACH ROW
EXECUTE FUNCTION log_customer_changes();
请谨慎使用此类代码。

💡 Informatica 側の設定

Informatica 側では、PostgreSQL の本番表（t_customer）だけを Target とし、通常通り更新（Update）処理を行うだけで完了します。履歴表への書き込みコードをマッピング内に記述する必要はありません。

4. 実装パターン 3：Informatica PowerExchange / Cloud CDC (Oracle ログベース)

Oracle の Redo ログ / 拡張ロギング（Supplemental Logging） を読み取り、PostgreSQL へリアルタイムにレプリケーションしつつ履歴を残す、エンタープライズ向けの構成です。
1. Oracle 側の準備:
   • Oracle データベース側で ARCHIVELOG モードを有効化。
   • 対象テーブルにサプリメンタル・ロギングを設定（ALTER TABLE customer ADD SUPPLEMENTAL LOG DATA (ALL) COLUMNS;）。
2. Informatica PWX / Cloud の挙動:
   • Oracle の Redo ログから「更新前の値（Before Image）」と「更新後の値（After Image）」の両方をキャプチャします。
3. PostgreSQL への書き込み:
   • ターゲット（PostgreSQL）のターゲットコネクタプロパティで「Operation Output = All / History」を選択することで、1つの UPDATE 文から「古い値のレコード」と「新しい値のレコード」を個別の行として PostgreSQL の履歴表に高速にインサートすることが可能です。
   Oracle から PostgreSQL への移行において：
   • 今回はワンタイム（一回限り）のデータ移行時の履歴取得ですか？それとも移行後の日常的なバッチ/リアルタイム運用時の履歴取得ですか？
   • もし実装パターン 2 の PostgreSQL 側のトリガー方式 に興味がある場合、実際のテーブル定義（カラム名など）を教えていただければ、それに合わせた具体的な PL/pgSQL コードを生成することも可能です。

---

* **テーブル間の依存関係**: AテーブルはBテーブルを参照し、BテーブルはCテーブルを参照します（$A \rightarrow B \rightarrow C$ のカスケード関係）。
* **データ生成**: A、B、C の3つのテーブルを結合・集約して、最終的な **Dテーブル** を生成します。
* **トリガー条件**: **A、B、C のいずれかのテーブルに変更（更新・追加・削除）が発生した場合にのみ** Dテーブルを更新・生成し、変更がない不要なタイミングでは処理を実行しません。
* **変更履歴生成**: Dテーブルの変更履歴を **Eテーブル** に自動生成します。
* **3時間毎1回実行する**
* **Oracle to PostgreSQL**

---

# Informatica 実装方案：Oracle(A/B/C) → PostgreSQL(D) ＋ 変更履歴(E) ／ 変更時のみ・3時間毎

本ドキュメントは、上記の要件を Informatica（PowerCenter / IDMC）で実現するための設計方案です。Oracle に存在する A・B・C（カスケード FK）を結合・集約して PostgreSQL の D を生成し、D の変更履歴を E に自動蓄積する構成を解説します。

## 1. 要件 → 実装方針の対応

| 要件 | 実装方針 |
|---|---|
| A→B→C のカスケード参照 | FK 保証があるため結合は **INNER JOIN** で欠損なし。Informatica の Joiner（または Oracle 側ビュー）で結合 |
| A+B+C 結合・集約 → D | Mapping `m_build_D`：Source Qualifier → Joiner ×2 → Aggregator → Update Strategy |
| **変更があった時のみ** D を更新 | **水位（Watermark）比較**で A/B/C の変更有無を判定し、変更なしなら本処理を抑止 |
| D の変更履歴 → E | **推奨：PostgreSQL の AFTER ROW トリガー**（Informatica を汚さない）。代替：Mapping 内ダブルライト |
| 3時間毎 | ワークフローのスケジュール Repeat（00:00 / 03:00 / 06:00 …）＋ 多重起動防止 |
| Oracle → PostgreSQL | タイプ変換・識別子小文字化・日時型・UPSERT 対応（§9） |

## 2. 前提条件と水位管理表

### 2.1 前提

* A/B/C には **主キー（PK）** と **`UPDATED_AT`（最終更新日時）** が存在する。
* 削除（DELETE）は `MAX(UPDATED_AT)` では検知できないため、**`COUNT(*)` 併用** または **論理削除フラグ（`DEL_FLG` + `UPDATED_AT`）** で検知する。
* D は PostgreSQL 側の集計結果テーブル、E は PostgreSQL 側の履歴テーブル。

### 2.2 水位管理表（Oracle 側・1行 = 1テーブル）

```sql
CREATE TABLE ETL_WMARK (
  TABLE_NAME  VARCHAR2(30) NOT NULL PRIMARY KEY,  -- 'A','B','C'
  MAX_UPD_TS  TIMESTAMP,                          -- 最終更新日時の最大値
  ROW_CNT     NUMBER,                             -- 行数（DELETE検知用）
  CHECKED_TS  TIMESTAMP                           -- 最終チェック日時
);
INSERT INTO ETL_WMARK VALUES ('A', NULL, NULL, NULL);
INSERT INTO ETL_WMARK VALUES ('B', NULL, NULL, NULL);
INSERT INTO ETL_WMARK VALUES ('C', NULL, NULL, NULL);
```

> 水位表を Oracle（ソース）側に置くことで、変更チェックを **1本の SQL** で完結させ、ソースへの負荷を最小化できます。

## 3. 全体アーキテクチャ

```
【Oracle】
  A ──FK──► B ──FK──► C        （A→B→C カスケード）
   │          │          │
   └── 毎3時間：MAX(UPDATED_AT) / COUNT(*) を水位(ETL_WMARK)と比較 ──┐
                                                                      ▼
【Informatica PowerCenter】
  [スケジュール: 毎3時間]
   ├─ WF1_CHG_CHECK（変更チェック）
   │    Command タスク：水位比較 SQL を実行
   │      ├─ 変更あり → pmcmd で WF2_BUILD_D を起動
   │      └─ 変更なし → 何もしない（Email/ログのみ）
   │
   └─ WF2_BUILD_D（本処理・変更時のみ起動）
        Session m_build_D:
        Oracle A/B/C → Joiner → Aggregator → Lookup(D) → Update Strategy
                                       │
                                       ▼
【PostgreSQL】
  D（集計結果）── AFTER TRIGGER ──► E（変更履歴）
  Post-SQL: ETL_WMARK を更新（成功時のみ水位を進める）
```

**ポイント**

* 「3時間毎に起動」するのは**チェックだけ**。実データの抽出・結合・書き込みは変更がある時だけ実行されます。
* 水位更新は **本処理成功後の Post-SQL** で行うため、失敗時は水位が進まず、次回スケジュールで自動的に再処理されます（リトライ安全）。

## 4. 変更検知（トリガー条件）の実装

### 4.1 変更チェック SQL（Command タスク内 / Pre-Session SQL）

```sql
SELECT COUNT(*) AS CHG_CNT
FROM (
  SELECT 'A' AS TBL, MAX(UPDATED_AT) AS TS, COUNT(*) AS CNT FROM A
  UNION ALL SELECT 'B', MAX(UPDATED_AT), COUNT(*) FROM B
  UNION ALL SELECT 'C', MAX(UPDATED_AT), COUNT(*) FROM C
) s
JOIN ETL_WMARK w ON w.TABLE_NAME = s.TBL
WHERE NVL(s.TS, TO_DATE('19700101','YYYYMMDD')) <> NVL(w.MAX_UPD_TS, TO_DATE('19700101','YYYYMMDD'))
   OR NVL(s.CNT, -1) <> NVL(w.CNT, -1);
-- 0        → 変更なし（本処理をスキップ）
-- 1以上    → 変更あり（D の再生成/更新を実行）
```

### 4.2 水位更新 SQL（本処理成功後の Post-SQL / Command）

```sql
MERGE INTO ETL_WMARK w
USING (
  SELECT T, MAX(UPDATED_AT) AS TS, COUNT(*) AS CNT
  FROM (
    SELECT 'A' T, UPDATED_AT FROM A
    UNION ALL SELECT 'B', UPDATED_AT FROM B
    UNION ALL SELECT 'C', UPDATED_AT FROM C
  ) GROUP BY T
) s ON (w.TABLE_NAME = s.T)
WHEN MATCHED THEN UPDATE SET
  w.MAX_UPD_TS = s.TS,
  w.ROW_CNT    = s.CNT,
  w.CHECKED_TS = SYSTIMESTAMP;
```

### 4.3 実装方式の比較

| 案 | 内容 | 長所 | 短所 |
|---|---|---|---|
| **A（推奨）** | 毎3時間の起点を「チェック用ワークフロー」にし、Command タスク（sqlplus）で水位比較 → **変更ありの場合のみ `pmcmd` で本処理ワークフローを起動** | セッション自体が起動しない＝無駄な処理が一切発生しない。確実でどの PowerCenter 版でも可 | シェル + pmcmd のラッパーが必要 |
| B | 本処理マッピング内で Source Qualifier（SQL Override）により「変更フラグ 1 行」を生成 → Router で分岐。変更なしなら 0 行が流れ、D/E への書き込みも発生しない | 追加ワークフロー不要。バージョン依存なし | セッションは起動する（軽量な水位クエリのみ） |
| C | Pre-Session SQL で水位比較結果を `$$CHG` 等に取得し、Decision タスクで本セッションを条件分岐 | 単一ワークフローで完結 | 変数取得の構文がバージョン・設定に依存 |
| D | Oracle 側トリガーで「変更フラグ表」に即時反映、または PWX / Cloud CDC でログベース変更検知 | リアルタイム性が高い | 追加ライセンス・ソース側トリガー運用が必要 |

> 「変更がない不要なタイミングでは処理を実行しない」を厳密に満たすのは **案 A**。開発工数を最小にしたい場合は **案 B** で「書き込みゼロ」を保証する構成でも要件を満たします。

## 5. 誤検知（False Positive）の防止 — A が事主表、B/C が補助表の場合

### 5.1 何が起きるか

水位が「テーブル単位・全列」の `MAX(UPDATED_AT)` / `COUNT(*)` だけだと、**D の生成に影響しない列の UPDATE** でも「変更あり」と誤判定します。
例：C の更新列が D に使われない列（補助表のメモ列等）だった場合：

1. 水位が進む → 本処理（D 再生成）が 1 回実行される（**誤起動**）
2. D の内容は不変 → UPSERT なら同値 UPDATE のみ（WAL・死 tuple 増）、全再構築なら全表書換
3. E の履歴：UPSERT + トリガー比較なら誤記録なし。ただし D に `LOAD_TS` 等の技術列があると全行が「実変更」となり履歴が肥大

### 5.2 誤検知を生む 2 つの要因と、2 段フィルタ

誤検知は「**列スコープ**」と「**行スコープ**」に分解できます。A（事主）→ B → C（補助）という FK カスケードがあるため、**A から参照される行だけが D に影響する**という性質を併用します。

```
                     C テーブルで UPDATE が発生
                              │
              ┌───────────────▼────────────────┐
   ① 列スコープ判定 │  D 生成に使う列が変化したか？   │
              │  （使用列のみ比較 / ハッシュ化）    │
              └───────────────┬────────────────┘
                      いいえ │            │ はい
        ┌────────────────────┘             ▼
        │                      ┌─────────────────────────┐
        │                      │ ② 行スコープ判定          │
        │                      │  A → B → C の FK で      │
        │                      │  A から参照される行か？    │
        │                      └────────────┬────────────┘
        │                          いいえ │             │ はい
        ▼                                  ▼             ▼
  水位は進まない                      水位は進まない     水位が進む
  → D の再生成を行わない              （参照外の行）     → D 再生成 + E 記録
  （誤検知を防止）                    （誤検知を防止）     （正検知）
```

### 5.3 案1：使用列ハッシュ水位（追加構成不要・推奨）

水位表の保持値を「`MAX(UPDATED_AT)`」から「**使用列のみを連結したハッシュの合計 + 行数**」に変更します。行範囲は `EXISTS` で A から参照される行に限定します（FK 列へのインデックスが必須）。

```sql
CREATE TABLE ETL_WMARK (
  TABLE_NAME VARCHAR2(30) PRIMARY KEY,
  HASH_VAL   NUMBER,      -- 使用列ハッシュの合計
  ROW_CNT    NUMBER,
  CHECKED_TS TIMESTAMP
);
```

```sql
-- C：A の参照チェーン上の行のみ、D で使用する列のみをハッシュ化
SELECT NVL(SUM(ORA_HASH(
         NVL(TO_CHAR(c.use_col1),'#') || '|' ||
         NVL(TO_CHAR(c.use_col2),'#'))), 0) AS HASH_VAL,
       COUNT(*) AS CNT
FROM C c
WHERE EXISTS (SELECT 1 FROM B b
               WHERE b.c_id = c.c_id
                 AND EXISTS (SELECT 1 FROM A a WHERE a.b_id = b.b_id));

-- B：B の使用列のみハッシュ、行範囲は A に参照される B のみ
-- A：事主表。使用列のみハッシュ（LOAD_TS 等の技術列は除外）
```

判定は §4.1 と同様、`HASH_VAL` または `ROW_CNT` が前回と相違すれば「変更あり」。

* 使用外列の UPDATE → ハッシュ不変 → 誤検知なし
* 参照外行の UPDATE/DELETE → `EXISTS` で除外 → 誤検知なし
* INSERT / DELETE → `ROW_CNT` の変化で検知
* 代償：3 時間毎に「参照行のハッシュ集計」が走る（中小テーブル向き）

### 5.4 案2：使用列トリガー + 変更ログ（チェックを最軽量化）

DML 時点で「使用列が変わった行」だけをログに残し、3 時間毎のチェックは `COUNT(*)` だけにします。

```sql
CREATE TABLE C_CHG (C_ID NUMBER, CHG_TS TIMESTAMP);

CREATE OR REPLACE TRIGGER trg_c_chg
AFTER INSERT OR UPDATE OR DELETE ON C
FOR EACH ROW
BEGIN
  IF INSERTING
     OR NVL(:NEW.use_col1,CHR(0)) <> NVL(:OLD.use_col1,CHR(0))
     OR NVL(:NEW.use_col2,CHR(0)) <> NVL(:OLD.use_col2,CHR(0)) THEN
    INSERT INTO C_CHG(C_ID, CHG_TS)
    VALUES (NVL(:NEW.C_ID, :OLD.C_ID), SYSTIMESTAMP);  -- 使用外列は記録されない
  END IF;
END;
/
```

```sql
-- 3 時間毎のチェック（行スコープはチェック側で適用）
SELECT COUNT(*) FROM C_CHG c
WHERE c.CHG_TS > (SELECT MAX_UPD_TS FROM ETL_WMARK WHERE TABLE_NAME='C')
  AND EXISTS (SELECT 1 FROM B b JOIN A a ON a.b_id = b.b_id
               WHERE b.c_id = c.C_ID);  -- A に参照されない変更は無視
```

`EXISTS` をトリガー内に置かない（業務 DML を遅くしないため）。記録は全件、絞り込みはチェック側で行います。

### 5.5 案3：快速リフレッシュ・マテビュー（列精度は Oracle が保証）

```sql
CREATE MATERIALIZED VIEW LOG ON C
  WITH ROWID, SEQUENCE (use_col1, use_col2)  -- 使用列のみ指定
  INCLUDING NEW VALUES;
```

MV ログは**指定列に変化があった行だけ**を記録するため、列スコープの絞り込みが宣言的に成立します。`MVIEW$_LOG` の行数/時刻を水位にすれば、チェックはさらに軽くなります。D の再構築が重く「変更キーだけの部分再集計」を狙う場合に適合します。

### 5.6 方式比較

| | 案1：ハッシュ水位 | 案2：トリガー + 変更ログ | 案3：マテビュー |
|---|---|---|---|
| 列スコープ（使用列のみ） | 可（手書き） | 可（トリガー条件） | 可（列指定） |
| 行スコープ（A 参照のみ） | 可（EXISTS） | 可（チェック側 EXISTS） | 部分的（ログは全行） |
| 3 時間毎のチェック負荷 | 中（参照行を集計） | **最小**（COUNT のみ） | 小 |
| 本番 DB 負荷 | ゼロ | DML 時に微増 | DML 時にログ書込 |
| 追加ライセンス | 不要 | 不要 | 不要 |
| 向く場面 | 中小テーブル・列数が少ない | 大テーブル・変更頻度が高い | D 再構築が重い |

### 5.7 併せて行う対策

* **A（事主表）も同様に**使用列のみをハッシュ/比較し、`LOAD_TS`・`BATCH_ID` 等の技術列は水位計算から除外する。
* **E の履歴トリガー**も技術列を除外する（`to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW)` を業務列に絞る、または業務列ハッシュ列 `D_HASH` を D に持たせて比較する）。
* 最適化：変更キーの一覧を Mapping に渡し、**影響する集約キーだけを再集計 → UPSERT** する部分再構築にすれば、「誤検知なし」かつ「変更時も差分だけ」になります。

## 6. Mapping 設計（m_build_D）

### 6.1 データフロー

```
[A (Oracle)] ──┐
                ├─► [Joiner J1: A.B_ID = B.B_ID] ─┐
[B (Oracle)] ───┘                                  ├─► [Joiner J2: B.C_ID = C.C_ID]
                                                   │
[C (Oracle)] ──────────────────────────────────────┘
      │
      ▼
[Expression: 派生列・日付/型変換（Oracle→PG）]
      ▼
[Aggregator: GROUP BY 集約キー + SUM/COUNT/MAX]
      ▼
[Lookup D (PostgreSQL): 主キーで既存有無を確認]
      ▼
[Router / Expression: 新規=DD_INSERT, 既存=DD_UPDATE, 消滅=DD_DELETE]
      ▼
[Update Strategy] ──► [D (PostgreSQL)]
```

### 6.2 設計上のポイント

* **結合方向**：A は B を、B は C を参照する（FK）ため、`A → B → C` の順に Joiner を接続。FK の整合性が保証されているので **INNER JOIN** でよい。
* **ソート結合**：Source Qualifier の ORDER BY または Oracle 側インデックスで整列してから **Sorted Merge Joiner** を使うと負荷が大きく下がる。
* **結合の事前実行（性能対策）**：A/B/C の結合が重い場合は、Oracle 側に **ビュー / マテビュー `V_AB_C`** を作り、単一ソース化して Informatica では集約のみ行う構成を推奨。
* **集約ロジックの例**：

```sql
-- D の生成ロジックイメージ
SELECT a.a_id, a.area, b.b_class, c.c_type,
       COUNT(*)        AS rec_cnt,
       SUM(a.amount)   AS sum_amt,
       MAX(c.price)    AS max_price
FROM a JOIN b ON a.b_id = b.b_id
       JOIN c ON b.c_id = c.c_id
GROUP BY a.a_id, a.area, b.b_class, c.c_type;
```

### 6.3 D の書き込み方法の2パターン

| パターン | 内容 | 用途 |
|---|---|---|
| **1. 差分反映（UPSERT）※推奨** | Lookup(D) で存在確認し、新規=DD_INSERT / 既存=DD_UPDATE / 新セットに無い行=DD_DELETE。PostgreSQL ターゲットの Insert / Update を両方有効化 | D が他システムから常に読まれる場合。D が空になる時間帯ができない |
| 2. 全再構築 | セッションの「Issue Truncate」＋ 一時テーブル D_NEW に全件ロード → `ALTER TABLE ... RENAME` で瞬時に切り替え | 集計が重く差分化できない場合。切り替えが原子的 |

## 7. E テーブル（D の変更履歴）の自動生成

### 方式 1：PostgreSQL トリガー（推奨）

Informatica は D への書き込みのみを行い、履歴は PostgreSQL 側トリガーに完全委譲します。マッピングが単純になり、D を直接更新する他の経路（手動 SQL 等）でも履歴が残ります。

```sql
-- E（履歴表）
CREATE TABLE D_HIST (
  HIST_ID    BIGSERIAL PRIMARY KEY,
  D_KEY      JSONB,                -- 主キー（丸ごと保持）
  CHG_TYPE   VARCHAR(1) NOT NULL,  -- I / U / D
  OLD_VAL    JSONB,
  NEW_VAL    JSONB,
  BATCH_ID   VARCHAR(50),          -- Informatica セッション/バッチID
  CHG_TS     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_d_hist_ts ON D_HIST (CHG_TS);

CREATE OR REPLACE FUNCTION fn_d_audit() RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO D_HIST(D_KEY, CHG_TYPE, OLD_VAL, NEW_VAL, BATCH_ID)
    VALUES (to_jsonb(NEW), 'I', NULL, to_jsonb(NEW), current_setting('app.batch_id', TRUE));
  ELSIF TG_OP = 'UPDATE' THEN
    IF to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW) THEN   -- 実際に変化した行のみ
      INSERT INTO D_HIST(D_KEY, CHG_TYPE, OLD_VAL, NEW_VAL, BATCH_ID)
      VALUES (to_jsonb(NEW), 'U', to_jsonb(OLD), to_jsonb(NEW), current_setting('app.batch_id', TRUE));
    END IF;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO D_HIST(D_KEY, CHG_TYPE, OLD_VAL, NEW_VAL, BATCH_ID)
    VALUES (to_jsonb(OLD), 'D', to_jsonb(OLD), NULL, current_setting('app.batch_id', TRUE));
  END IF;
  RETURN NULL;  -- AFTER トリガーなので戻り値は不要
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_d_audit
AFTER INSERT OR UPDATE OR DELETE ON D
FOR EACH ROW EXECUTE FUNCTION fn_d_audit();
```

* `BATCH_ID` は Informatica のセッション Pre-SQL（PostgreSQL 接続）で `SELECT set_config('app.batch_id', '$$BATCH_ID', false);` と設定しておけば、履歴からどのバッチの产物かを追跡できます。
* `to_jsonb(OLD) IS DISTINCT FROM to_jsonb(NEW)` により、値が実質変化しない UPDATE（同値書き込み）では履歴が増えない。

### 方式 2：Informatica 内でダブルライト

PostgreSQL トリガーを使わず、マッピング内で履歴を作る方式（冒頭「アプローチ1」と同じ発想）。

```
Lookup D（旧値取得） ─► Expression（v_FLAG: INSERT/UPDATE/DELETE/NO_CHANGE 判定）
      ─► Router ─┬─ DD_UPDATE / DD_INSERT ─► D
                 └─ Expression（sysdate, BATCH_ID 付与） ─► E（常に INSERT）
```

| | 方式1：PGトリガー | 方式2：Mapping ダブルライト |
|---|---|---|
| 開発工数 | 少ない（DDL のみ） | 大きい（Lookup/Router/Update Strategy） |
| 履歴の一貫性 | D への全経路を捕捉（手動 SQL も含む） | Informatica 経由のみ |
| 本番負荷 | PG 側に微負荷 | ETL セッション内で完結 |
| 推奨用途 | **本方案** | トリガー禁止ポリシーがある環境 |

## 8. 3時間毎のスケジュール設定

| 環境 | 設定箇所 |
|---|---|
| PowerCenter | Workflow → Scheduling → **Repeat: Every 3 hours**（開始時刻を 00:00 等の境界に合わせる） |
| Control-M 等の外部スケジューラ | 00:00 / 03:00 / 06:00 … にワークフローを定義し、Informatica 側スケジュールは無効化 |
| IDMC（クラウド） | Task/Task Flow の Schedule → **Repeat → Interval: 3 hours** |

**多重起動防止**

* ワークフローの「Allow concurrent run」を無効化する。
* 前回実行が長引いた場合：次の3時間境界で前バッチの終了を **Event Wait / Predecessor** で待ち、二重実行を防ぐ。
* 遅延が発生しても水位が前進していれば「変更なし」と判定されるため、**取りこぼしは発生しない**（差分は常に水位比較で捕捉される）。

## 9. Oracle → PostgreSQL 移行時の変換ポイント

| Oracle | PostgreSQL | 備考 |
|---|---|---|
| 識別子（表名・列名）大文字 | 小文字（クォートなし） | Informatica のソース/ターゲット定義名を小文字に統一 |
| `NUMBER` | `INTEGER` / `BIGINT` / `NUMERIC` | 集計値は精度優先で `NUMERIC` |
| `VARCHAR2` | `VARCHAR` / `TEXT` | |
| `DATE`（時刻含む） | `TIMESTAMP(0)` | |
| `TIMESTAMP` | `TIMESTAMP` / `TIMESTAMPTZ` | D/E は `TIMESTAMPTZ` 推奨 |
| `SYSDATE` / `SYSTIMESTAMP` | `now()` / `CURRENT_TIMESTAMP` | Informatica 内は共通関数 `sysdate` でも可 |
| `SEQUENCE` | `BIGSERIAL` / `GENERATED ... AS IDENTITY` | `D_HIST.HIST_ID` は `BIGSERIAL` |
| `MERGE` | `INSERT ... ON CONFLICT (pk) DO UPDATE` | UPSERT は Update Strategy（DD_INSERT/DD_UPDATE）で代替 |
| 空文字 `''` | `NULL` | Oracle は `''`=`NULL`。PostgreSQL は別物。Informatica 側で明示変換 |
| `NVL` / `DECODE` | `COALESCE` / `CASE` | SQL Override を書く場合に注意 |

## 10. 実装チェックリスト

* [ ] A/B/C に PK・`UPDATED_AT` を追加（無い場合）。削除検知は `COUNT(*)` 差分または論理削除フラグ化
* [ ] Oracle に `ETL_WMARK`（水位管理表）を作成し、初期投入
* [ ] `UPDATED_AT` にインデックスを作成
* [ ] 変更チェック用ワークフロー `WF1_CHG_CHECK`（sqlplus + pmcmd）を作成
* [ ] `m_build_D`（Joiner → Aggregator → Lookup(D) → Update Strategy）を作成、D の書込方式を UPSERT / 全再構築から選択
* [ ] PostgreSQL に `D`・`D_HIST` とトリガー `trg_d_audit` を作成
* [ ] セッション Pre-SQL で `app.batch_id` を設定（履歴トレース用）
* [ ] Post-SQL で水位更新（成功時のみ水位が進むこと）
* [ ] スケジュールを3時間毎に設定し、多重起動を禁止
* [ ] 初回実行：水位が NULL のため全量一致＝変更ありと判定され、D が初期構築される（初回ロードを兼ねる）
* [ ] 失敗時リトライ、Email 通知、実行ログ（スキップ/実行の記録）を整備

## 11. 運用上の注意

* **負荷**：3時間毎の水位チェックは 3 テーブルの `MAX`/`COUNT` のみで極めて軽い。ただし `UPDATED_AT` にインデックスが無いと全件スキャンになるため、**`UPDATED_AT` への索引作成は必須**。
* **集計コスト**：A/B/C の結合・集約が重い場合は、Oracle 側のマテビュー（`REFRESH FAST ON DEMAND`）を検討。マテビュー更新自体も変更検知の対象にできる。
* **履歴の肥大化**：`D_HIST` は3時間毎に増加するため、`CHG_TS` のインデックス＋定期的なアーカイブ/パーティション化を推奨。
* **D の読み手**：D を他システムが読むタイミングに合わせて、UPSERT（パターン1）か一時テーブル swap（パターン2）かを選択する。


