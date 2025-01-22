from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from models.transaction import Transaction
from schemas.transaction import TransactionCreate, Transaction
from config.database import get_db

router = APIRouter()

@router.post("/", response_model=Transaction)
async def create_transaction(
    transaction: TransactionCreate, 
    db: AsyncSession = Depends(get_db)
):
    db_transaction = Transaction(**transaction.dict())
    db.add(db_transaction)
    await db.commit()
    await db.refresh(db_transaction)
    return db_transaction

@router.get("/", response_model=list[Transaction])
async def get_transactions(
    skip: int = 0, 
    limit: int = 100, 
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Transaction).offset(skip).limit(limit))
    return result.scalars().all()

@router.delete("/{transaction_id}")
async def delete_transaction(
    transaction_id: int, 
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(
        select(Transaction).where(Transaction.id == transaction_id)
    )
    transaction = result.scalar_one_or_none()
    
    if not transaction:
        raise HTTPException(status_code=404, detail="Transaction not found")
    
    await db.delete(transaction)
    await db.commit()
    return {"message": "Transaction deleted"}