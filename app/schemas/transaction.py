from pydantic import BaseModel
from datetime import datetime

class TransactionBase(BaseModel):
    type: str
    description: str
    amount: float
    date: datetime

class TransactionCreate(TransactionBase):
    pass

class Transaction(TransactionBase):
    id: int

    class Config:
        orm_mode = True