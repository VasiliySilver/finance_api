from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from models.loan import Loan
from schemas.loan import LoanCreate, Loan
from config.database import get_db

router = APIRouter()

@router.post("/", response_model=Loan)
async def create_loan(
    loan: LoanCreate, 
    db: AsyncSession = Depends(get_db)
):
    db_loan = Loan(
        **loan.dict(),
        remaining_amount=loan.total_amount,
        status="active"
    )
    db.add(db_loan)
    await db.commit()
    await db.refresh(db_loan)
    return db_loan

@router.post("/{loan_id}/repay")
async def repay_loan(
    loan_id: int, 
    amount: float, 
    db: AsyncSession = Depends(get_db)
):
    result = await db.execute(select(Loan).where(Loan.id == loan_id))
    loan = result.scalar_one_or_none()
    
    if not loan:
        raise HTTPException(status_code=404, detail="Loan not found")
    
    if amount <= 0 or amount > loan.remaining_amount:
        raise HTTPException(status_code=400, detail="Invalid repayment amount")
    
    loan.remaining_amount -= amount
    if loan.remaining_amount == 0:
        loan.status = "paid"
    
    await db.commit()
    await db.refresh(loan)
    return loan