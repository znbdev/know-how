from __future__ import annotations
from dataclasses import dataclass, field, asdict
from typing import Optional
from datetime import datetime


STATUSES = ["未開始", "進行中", "ブロック", "完了", "キャンセル"]
STATUS_ICONS = ["🟩", "🟨", "🟦", "⬜", "❌"]

PRIORITIES = ["P0-緊急", "P1-高", "P2-中", "P3-低"]
PRIORITY_ICONS = ["🔴", "🟠", "🟡", "🔵"]

TASK_TYPES = ["機能開発", "バグ修正", "技術最適化", "調査分析", "ドキュメント作成", "その他"]

PHASES = ["1. 調査・設計", "2. 実装・開発", "3. レビュー・最適化", "4. 納品・クローズ"]


@dataclass
class WBSItem:
    phase: str = ""
    task_name: str = ""
    estimated_hours: float = 0.0
    actual_hours: float = 0.0
    progress: str = ""
    notes: str = ""


@dataclass
class DailyLogItem:
    date: str = ""
    items: list = field(default_factory=list)
    notes: str = ""


@dataclass
class RiskItem:
    description: str = ""
    mitigation: str = ""


@dataclass
class ChangeHistoryItem:
    date: str = ""
    change: str = ""
    changed_by: str = ""


@dataclass
class Task:
    id: str = ""
    title: str = ""
    description: str = ""
    status: str = STATUSES[0]
    priority: str = PRIORITIES[2]
    task_type: str = TASK_TYPES[0]
    owner: str = ""
    requester: str = ""
    start_date: str = ""
    due_date: str = ""
    core_objective: str = ""
    deliverables: list = field(default_factory=list)
    success_criteria: list = field(default_factory=list)
    wbs_items: list = field(default_factory=list)
    risks: list = field(default_factory=list)
    external_dependencies: list = field(default_factory=list)
    buffer_hours: float = 0.0
    daily_logs: list = field(default_factory=list)
    resources: list = field(default_factory=list)
    change_history: list = field(default_factory=list)
    created_at: str = ""
    updated_at: str = ""
    tags: list = field(default_factory=list)

    @property
    def total_estimated(self) -> float:
        return sum(item.estimated_hours for item in self.wbs_items)

    @property
    def total_actual(self) -> float:
        return sum(item.actual_hours for item in self.wbs_items)

    @property
    def deviation_rate(self) -> Optional[float]:
        if self.total_estimated == 0:
            return None
        return ((self.total_actual - self.total_estimated) / self.total_estimated) * 100

    @property
    def status_icon(self) -> str:
        idx = STATUSES.index(self.status) if self.status in STATUSES else 0
        return STATUS_ICONS[idx]

    @property
    def priority_icon(self) -> str:
        idx = PRIORITIES.index(self.priority) if self.priority in PRIORITIES else 0
        return PRIORITY_ICONS[idx]

    def to_dict(self) -> dict:
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> Task:
        wbs_items = [WBSItem(**item) if isinstance(item, dict) else item for item in data.get("wbs_items", [])]
        daily_logs = [DailyLogItem(**item) if isinstance(item, dict) else item for item in data.get("daily_logs", [])]
        data["wbs_items"] = wbs_items
        data["daily_logs"] = daily_logs
        return cls(**data)
