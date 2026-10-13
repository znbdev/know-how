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


