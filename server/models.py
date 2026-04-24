from pydantic import BaseModel
from typing import List

class RuleScore(BaseModel):
    rule_id: str
    rule_name: str
    score: int
    feedback: str
    is_weak: bool

    def __init__(self, **data):
        super().__init__(**data)

class TajwidAnalysisResult(BaseModel):
    overall_score: int
    feedback: str
    grade: str
    rule_scores: List[RuleScore]
    weak_words: List[str]
    weak_rule_ids: List[str]
    excellent_rule_ids: List[str]
    encouragement: str

    def __init__(self, **data):
        super().__init__(**data)
