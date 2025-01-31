from pydantic import BaseModel
from datetime import datetime

class LoanBase(BaseModel):
    lender: str
    total_amount: float
    received_date: datetime
    due_date: datetime

class LoanCreate(LoanBase):
    pass

class Loan(LoanBase):
    id: int
    remaining_amount: float
    status: str

    class Config:
        orm_mode = True