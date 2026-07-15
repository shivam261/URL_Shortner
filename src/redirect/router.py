from fastapi import APIRouter

router = APIRouter()

# router to redirect to that router 
# get the redirect url from postgres db 
# psuh the anaytical details to KMs 
# kms will save in dynamo db table 