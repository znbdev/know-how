#!/usr/bin/env python3
"""サンプルデータ生成スクリプト"""

import requests

API = "http://127.0.0.1:5800/api/tasks"

samples = [
    {
        "title": "ユーザー認証モジュール改修",
        "status": "進行中",
        "priority": "P0-緊急",
        "task_type": "機能開発",
        "owner": "田中",
        "requester": "佐藤",
        "start_date": "2026-06-10",
        "due_date": "2026-06-18",
        "core_objective": "OAuth2.0 対応とパスワードレス認証の追加",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "既存認証フロー分析", "estimated_hours": 2.0, "actual_hours": 1.5, "progress": "完了"},
            {"phase": "1. 調査・設計", "task_name": "OAuth2.0 技術調査", "estimated_hours": 3.0, "actual_hours": 2.0, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "OAuth クライアント実装", "estimated_hours": 6.0, "actual_hours": 4.0, "progress": "80%"},
            {"phase": "2. 実装・開発", "task_name": "トークン管理リファクタ", "estimated_hours": 4.0, "actual_hours": 0, "progress": "未着手"},
            {"phase": "3. レビュー・最適化", "task_name": "セキュリティレビュー", "estimated_hours": 2.0, "actual_hours": 0, "progress": "未着手"},
        ],
        "risks": [
            {"description": "サードパーティOAuthプロバイダの可用性", "mitigation": "複数プロバイダ対応とサーキットブレーカー"},
            {"description": "既存ユーザーセッションの移行", "mitigation": "段階的ロールアウト計画"},
        ],
        "external_dependencies": ["認証基盤チームのAPI提供", "セキュリティチームのレビュー"],
        "buffer_hours": 3.0,
        "daily_logs": [
            {"date": "2026-06-14", "items": ["OAuth クライアント実装 80%完了", "コードレビュー依頼"], "notes": "レビュー待ち時間が発生"},
        ],
    },
    {
        "title": "DB パフォーマンスチューニング",
        "status": "未開始",
        "priority": "P1-高",
        "task_type": "技術最適化",
        "owner": "鈴木",
        "requester": "システム部",
        "start_date": "2026-06-17",
        "due_date": "2026-06-24",
        "core_objective": "主要クエリの応答時間を50%以上改善",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "スロークエリログ分析", "estimated_hours": 3.0, "actual_hours": 0, "progress": ""},
            {"phase": "1. 調査・設計", "task_name": "インデックス戦略設計", "estimated_hours": 2.0, "actual_hours": 0, "progress": ""},
            {"phase": "2. 実装・開発", "task_name": "インデックス最適化", "estimated_hours": 4.0, "actual_hours": 0, "progress": ""},
            {"phase": "2. 実装・開発", "task_name": "クエリリライト", "estimated_hours": 3.0, "actual_hours": 0, "progress": ""},
        ],
        "risks": [{"description": "本番DBへの直接変更リスク", "mitigation": "ステージング環境で十分に検証後、変更管理プロセス経由で適用"}],
        "external_dependencies": ["DBA チームの権限申請"],
        "buffer_hours": 2.0,
    },
    {
        "title": "決済API 障害対応",
        "status": "ブロック",
        "priority": "P0-緊急",
        "task_type": "バグ修正",
        "owner": "高橋",
        "requester": "カスタマーサポート",
        "start_date": "2026-06-13",
        "due_date": "2026-06-16",
        "core_objective": "決済処理のタイムアウト障害を修正",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "エラーログ解析", "estimated_hours": 2.0, "actual_hours": 3.0, "progress": "完了"},
            {"phase": "1. 調査・設計", "task_name": "原因特定と再現確認", "estimated_hours": 2.0, "actual_hours": 2.5, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "修正コード実装", "estimated_hours": 3.0, "actual_hours": 0, "progress": "未着手"},
            {"phase": "3. レビュー・最適化", "task_name": "回帰テスト", "estimated_hours": 2.0, "actual_hours": 0, "progress": ""},
        ],
        "risks": [{"description": "決済プロバイダ側の仕様変更", "mitigation": "ベンダーに問い合わせ中"}],
        "external_dependencies": ["決済プロバイダからのAPI仕様書提供待ち"],
        "buffer_hours": 2.0,
    },
    {
        "title": "API ドキュメント自動生成",
        "status": "完了",
        "priority": "P2-中",
        "task_type": "ドキュメント作成",
        "owner": "伊藤",
        "requester": "開発部",
        "start_date": "2026-06-10",
        "due_date": "2026-06-14",
        "core_objective": "OpenAPI 仕様から自動生成されるドキュメントサイトの構築",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "ツール選定 (Swagger/Redoc)", "estimated_hours": 2.0, "actual_hours": 1.5, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "CIパイプライン構築", "estimated_hours": 4.0, "actual_hours": 3.0, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "デプロイ設定", "estimated_hours": 2.0, "actual_hours": 1.5, "progress": "完了"},
            {"phase": "3. レビュー・最適化", "task_name": "動作確認と調整", "estimated_hours": 2.0, "actual_hours": 1.0, "progress": "完了"},
            {"phase": "4. 納品・クローズ", "task_name": "チーム共有・展開", "estimated_hours": 1.0, "actual_hours": 0.5, "progress": "完了"},
        ],
        "daily_logs": [
            {"date": "2026-06-13", "items": ["Redoc でのドキュメント表示確認", "CI パイプライン完成"], "notes": ""},
        ],
        "change_history": [
            {"date": "2026-06-10", "change": "初回作成", "changed_by": "伊藤"},
            {"date": "2026-06-14", "change": "完了", "changed_by": "伊藤"},
        ],
    },
    {
        "title": "Notification サービス設計",
        "status": "未開始",
        "priority": "P1-高",
        "task_type": "調査分析",
        "owner": "山田",
        "requester": "プロダクトオーナー",
        "start_date": "2026-06-17",
        "due_date": "2026-06-28",
        "core_objective": "プッシュ通知・メール・in-app通知を統合する通知基盤の設計",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "要件整理", "estimated_hours": 3.0, "actual_hours": 0, "progress": ""},
            {"phase": "1. 調査・設計", "task_name": "既存通知処理の棚卸", "estimated_hours": 2.0, "actual_hours": 0, "progress": ""},
            {"phase": "1. 調査・設計", "task_name": "技術選定資料作成", "estimated_hours": 4.0, "actual_hours": 0, "progress": ""},
            {"phase": "2. 実装・開発", "task_name": "PoC 実装", "estimated_hours": 6.0, "actual_hours": 0, "progress": ""},
        ],
        "risks": [{"description": "対象範囲が広くスコープクリープの懸念", "mitigation": "MVP を明確に定義しフェーズ分割"}],
        "buffer_hours": 3.0,
    },
    {
        "title": "ログイン画面UI 実装",
        "status": "進行中",
        "priority": "P1-高",
        "task_type": "機能開発",
        "owner": "佐藤",
        "requester": "デザインチーム",
        "start_date": "2026-06-12",
        "due_date": "2026-06-19",
        "core_objective": "Figma デザインに準拠したログイン画面の実装",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "Figma デザイン確認", "estimated_hours": 1.0, "actual_hours": 1.0, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "HTML/CSS テンプレート作成", "estimated_hours": 4.0, "actual_hours": 3.0, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "フォームバリデーション実装", "estimated_hours": 3.0, "actual_hours": 1.5, "progress": "50%"},
            {"phase": "2. 実装・開発", "task_name": "エラーハンドリング", "estimated_hours": 2.0, "actual_hours": 0, "progress": ""},
            {"phase": "3. レビュー・最適化", "task_name": "クロスブラウザ確認", "estimated_hours": 2.0, "actual_hours": 0, "progress": ""},
        ],
    },
    {
        "title": "旧データ移行スクリプト",
        "status": "キャンセル",
        "priority": "P2-中",
        "task_type": "その他",
        "owner": "渡辺",
        "requester": "データチーム",
        "start_date": "2026-06-01",
        "due_date": "2026-06-10",
        "core_objective": "レガシーシステムから新システムへのデータ移行",
        "wbs_items": [
            {"phase": "1. 調査・設計", "task_name": "データマッピング定義", "estimated_hours": 4.0, "actual_hours": 3.0, "progress": "完了"},
            {"phase": "2. 実装・開発", "task_name": "移行スクリプト作成", "estimated_hours": 8.0, "actual_hours": 2.0, "progress": "中断"},
        ],
        "risks": [{"description": "データ不整合リスク", "mitigation": "バリデーションチェック実装"}],
        "change_history": [
            {"date": "2026-06-11", "change": "プロジェクト優先度変更によりキャンセル", "changed_by": "渡辺"},
        ],
    },
]


def post_task(task):
    r = requests.post(API, json=task)
    if r.status_code == 201:
        data = r.json()
        print(f"  ✅ [{data['status']}] {data['title']} (id={data['id']})")
        return data
    else:
        print(f"  ❌ {task['title']}: {r.status_code} {r.text}")
        return None


if __name__ == "__main__":
    print("サンプルデータ生成中...\n")
    for task in samples:
        post_task(task)
    print("\n全てのサンプルデータを生成しました。")
    print("http://127.0.0.1:5800 にアクセスして確認してください。")
