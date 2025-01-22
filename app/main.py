from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import transactions, loans
from config.database import engine, Base

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app.include_router(transactions.router, prefix="/api/transactions", tags=["transactions"])
app.include_router(loans.router, prefix="/api/loans", tags=["loans"])

@app.get("/")
async def read_root():
    return {"message": "Async Finance API"}