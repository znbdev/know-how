WITH merged AS (
MERGE INTO schm_datalink_test.m_packaging_code AS m -- 包装コードM
USING (
-- 最新の連携結果が処理中の場合のみWORKを取得する。
SELECT
w.packaging_code              -- 包装コード
, w.unit_dimension_code         -- 包装用型式コード
, w.individual_packaging_quantity -- 個装単位数量
FROM
schm_datalink_test.w_packaging_code AS w -- 包装コードWORK
WHERE
EXISTS (
SELECT
1
FROM
(
SELECT
execution_result -- 実行結果
FROM
schm_datalink_test.t_master_integration_result -- マスタ連携結果T
WHERE
change_history_id = 'm_packaging_code' -- 更新テーブルID
ORDER BY
integration_start_datetime DESC -- 最新の連携開始日時
LIMIT
1
) AS r
WHERE
r.execution_result = '' -- 処理中
)
) AS w
ON (
m.packaging_code = w.packaging_code -- 包装コード
AND m.unit_dimension_code = w.unit_dimension_code -- 包装用型式コード
)

    /*==================================================================
      UPDATE: 個装単位数量が異なる場合のみ更新する。
    ==================================================================*/
    WHEN MATCHED
        AND m.individual_packaging_quantity IS DISTINCT FROM w.individual_packaging_quantity THEN UPDATE
    SET
          individual_packaging_quantity = w.individual_packaging_quantity -- 個装単位数量
        , update_datetime = CURRENT_TIMESTAMP                             -- 更新日時
        , update_user_id = SESSION_USER                                   -- 更新ユーザーID
        , update_program_id = 'test_program_id'                          -- 更新プログラムID
        , version_number = m.version_number + 1                            -- バージョン番号

    /*==================================================================
      INSERT: WORKのみ存在すレコードを登録する。
    ==================================================================*/
    WHEN NOT MATCHED BY TARGET THEN
    INSERT (
          packaging_code              -- 包装コード
        , unit_dimension_code         -- 包装用型式コード
        , individual_packaging_quantity -- 個装単位数量
        , create_program_id           -- 作成プログラムID
    )
    VALUES (
          w.packaging_code              -- 包装コード
        , w.unit_dimension_code         -- 包装用型式コード
        , w.individual_packaging_quantity -- 個装単位数量
        , 'test_program_id'             -- 作成プログラムID
    )

    /*==================================================================
      DELETE: 全件連携かつWORK非空の場合のみ削除する。
    ==================================================================*/
    WHEN NOT MATCHED BY SOURCE
        AND EXISTS (
            SELECT
                1
            FROM
                (
                    SELECT
                          full_execution_category -- 全件実行区分
                        , execution_result        -- 実行結果
                    FROM
                        schm_datalink_test.t_master_integration_result -- マスタ連携結果T
                    WHERE
                        change_history_id = 'm_packaging_code' -- 更新テーブルID
                    ORDER BY
                        integration_start_datetime DESC -- 最新の連携開始日時
                    LIMIT
                        1
                ) AS r
            WHERE
                r.execution_result = ''             -- 処理中
                AND r.full_execution_category = '1'  -- 全件連携
        )
        AND EXISTS (
            SELECT
                1
            FROM
                schm_datalink_test.w_packaging_code -- 包装コードWORK
        ) THEN DELETE

    /*==================================================================
      RETURNING: MERGEで変更されたレコードの更新前後を取得する。
    ==================================================================*/
    RETURNING
        merge_action() AS action -- 更新種別 (INSERT / UPDATE / DELETE)
        , COALESCE(OLD.packaging_code, NEW.packaging_code) AS packaging_code -- 包装コード
        , COALESCE(
            OLD.unit_dimension_code
            , NEW.unit_dimension_code
        ) AS unit_dimension_code -- 包装用型式コード
        , OLD.individual_packaging_quantity AS old_quantity -- 更新前の個装単位数量
        , NEW.individual_packaging_quantity AS new_quantity -- 更新後の個装単位数量
)
/*==================================================================
MERGE実行結果の確認
INSERT / UPDATE / DELETEの実行結果を表示する。
==================================================================*/
SELECT
action       -- 更新種別
, packaging_code -- 包装コード
, unit_dimension_code -- 包装用型式コード
, old_quantity -- 更新前の個装単位数量
, new_quantity -- 更新後の個装単位数量
FROM
merged;