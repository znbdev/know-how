# A・B・Cテーブルの変更に基づくDテーブルのインクリメンタル更新設計（Oracle環境）

## 1. 要件定義

* **テーブル間の依存関係**: AテーブルはBテーブルを参照し、BテーブルはCテーブルを参照します（$A \rightarrow B \rightarrow C$ のカスケード関係）。
* **データ生成**: A、B、C の3つのテーブルを結合・集約して、最終的な **Dテーブル** を生成します。
* **トリガー条件**: **A、B、C のいずれかのテーブルに変更（更新・追加・削除）が発生した場合にのみ** Dテーブルを更新・生成し、変更がない不要なタイミングでは処理を実行しません。

---

## 2. 解決策のアプローチ（Oracle）

Oracle環境において、外部のスクリプト（PythonやJavaなど）を使わず、データベース内部だけで完結させるための純粋なSQLおよびPL/SQLによるソリューションです。

* **`MERGE INTO` の活用**: 存在チェック、条件判定（変更時間に基づくフィルタリング）、更新（Update）、挿入（Insert）を1つの文で効率的に行います。
* **`DBMS_SCHEDULER` の活用**: 外部の Cron などを利用せず、Oracle 内蔵のスケジューラーで定期的に変更をチェックします。

---

## 3. SQLの実装例

### ① Dテーブルの作成

```sql
CREATE TABLE table_d (
    id NUMBER PRIMARY KEY,
    summary_data VARCHAR2(500),
    last_generated_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

```

### ② 差分更新用ストアドプロシージャの作成

A、B、C の変更時刻が D の生成時刻より後である場合にのみ、更新または挿入を行いま​​す。

```sql
CREATE OR REPLACE PROCEDURE sp_incremental_update_d AS
BEGIN
    MERGE INTO table_d d
    USING (
        SELECT 
            a.id AS id,
            a.val_a || '-' || b.val_b || '-' || c.val_c AS summary_data,
            a.updated_at AS a_up,
            b.updated_at AS b_up,
            c.updated_at AS c_up
        FROM table_a a
        JOIN table_b b ON a.b_id = b.id
        JOIN table_c c ON b.c_id = c.id
    ) src
    ON (d.id = src.id)
    -- ソース側の更新時刻が D の生成時刻より新しい場合のみ更新
    WHEN MATCHED THEN
        UPDATE SET 
            d.summary_data = src.summary_data, 
            d.last_generated_at = SYSTIMESTAMP
        WHERE src.a_up > d.last_generated_at 
           OR src.b_up > d.last_generated_at 
           OR src.c_up > d.last_generated_at
    -- D テーブルに存在しない場合は新規挿入
    WHEN NOT MATCHED THEN
        INSERT (id, summary_data, last_generated_at)
        VALUES (src.id, src.summary_data, SYSTIMESTAMP);

    COMMIT;
END;
/

```

### ③ 定期実行ジョブ（DBMS_SCHEDULER）の作成

データベース内部で自動的に変更をチェックするためのスケジュールを設定します（例：1分ごとに実行）。

```sql
BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'JOB_AUTO_UPDATE_D',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'sp_incremental_update_d',
        repeat_interval => 'FREQ=MINUTELY;INTERVAL=1',
        enabled         => TRUE,
        comments        => 'A, B, C の変更を検知して D テーブルをインクリメンタル更新'
    );
END;
/

```

---

## 4. 本ソリューションのメリット

1. **効率的な差分更新**: 全量再生成ではなく、変更があったデータのみをターゲットにして更新するため、パフォーマンスに優れています。
2. **データベース内部で完結**: ストアドプロシージャとスケジューラーにより、外部プログラムの常駐が不要になります。
3. **安全なマージ処理**: Oracleの `MERGE INTO` により、競合を防ぎながら「存在すれば更新、なければ挿入」をスマートに実行できます。