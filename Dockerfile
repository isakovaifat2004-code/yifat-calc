FROM python:3.9-slim

WORKDIR /app

# התקנת Flask
RUN pip install flask

# העתקת הקבצים
COPY . .

# חשיפת הפורט
EXPOSE 5000

# הרצת האפליקציה
CMD ["python", "app.py"]
