FROM python:3.8-alpine
COPY . /app
WORKDIR /app
RUN pip3 install -r requirements.txt  
EXPOSE 5001
CMD ["python", "app.py"]
