# 🚀 クイックスタート - タスク管理ボード (Web UI)

## 必要環境

- Python 3.9+

### 依存ライブラリ（任意）

- **Flask**（`pip3 install flask`）— インストールされていれば優先使用
- **openpyxl**（`pip3 install openpyxl`）— Excel エクスポート機能に必要

どちらのライブラリも無い場合、Python 標準ライブラリのみで動作します（Excel エクスポートは無効）。

## 起動方法

```bash
cd python
python3 main.py
```

ブラウザで **http://127.0.0.1:5800** を開く。
（Mac では AirPlay Receiver がポート 5000 を使用中のため 5800 を使用）

## サンプルデータ

```bash
python3 seed_sample.py
```

7件のサンプルタスク（全ステータス網羅）を自動生成します。

## 使い方

### タスクの作成
- 画面上部の **「＋ 新規タスク」** をクリック

### タスクの編集
- カードを **クリック** → モーダルダイアログで編集
- タブ切替で WBS工数・リスク・Daily Log も編集可能

### ステータス変更
- カードを **ドラッグ＆ドロップ** で別カラムに移動

### 検索
- 画面上部の検索ボックスでフィルタリング

## データ保存場所

```
python/data/tasks.json
```

JSON 形式で自動保存。手動編集も可能。

## ファイル構成

```
python/
├── main.py              # エントリーポイント（Flask → 標準ライブラリに自動フォールバック）
├── webapp.py            # Flask API + ルーティング（Flask インストール時のみ）
├── server_native.py     # 標準ライブラリ版 HTTP サーバ（フォールバック用）
├── models.py            # データモデル
├── storage.py           # JSON ファイル入出力
├── seed_sample.py       # サンプルデータ生成
├── templates/
│   └── index.html       # カンバンボード UI
├── data/tasks.json      # タスクデータ
└── QUICKSTART.md        # このファイル
```
