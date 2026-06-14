# 🚀 クイックスタート - タスク管理ボード (Web UI)

## 必要環境

- Python 3.9+
- Flask（`pip3 install flask`）

## 起動方法

```bash
cd python
python3 main.py
```

ブラウザで **http://127.0.0.1:5800** を開く。
（macOS では AirPlay Receiver がポート 5000 を使用中のため 5800 を使用）

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
├── main.py              # エントリーポイント
├── webapp.py            # Flask API + ルーティング
├── models.py            # データモデル
├── storage.py           # JSON ファイル入出力
├── seed_sample.py       # サンプルデータ生成
├── templates/
│   └── index.html       # カンバンボード UI
├── data/tasks.json      # タスクデータ
└── QUICKSTART.md        # このファイル
```
