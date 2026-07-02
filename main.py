from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "Hello"}

# Add this endpoint to satisfy validate.sh
@app.get("/health")
def health_check():
    return {"status": "healthy"}