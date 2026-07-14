import os
from fastapi import FastAPI,Response
from contextlib import asynccontextmanager

from dotenv import load_dotenv
import logging 
load_dotenv()
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting up...")
    yield
    logger.info("Shutting down...")

app = FastAPI(lifespan=lifespan)

@app.get("/")
async def read_root():
    """
    this route return hello from the server
    """
    return {"message": "i am shivam tripathi"}
