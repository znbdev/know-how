#!/usr/bin/env python3
"""タスク管理ボード - Task Management Board (Web UI)

Usage:
  python3 main.py
  -> Open http://127.0.0.1:5000
"""

from webapp import app

if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5800)
