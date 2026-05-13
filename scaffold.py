import os

base_dir = "backend"

dirs = [
    "app/models",
    "app/schemas",
    "app/routes",
    "app/services",
    "app/middleware",
    "app/utils"
]

files = {
    "app/__init__.py": "",
    "app/main.py": "",
    "app/config.py": "",
    "app/database.py": "",
    "app/models/__init__.py": "",
    "app/models/user.py": "",
    "app/models/course.py": "",
    "app/models/lesson.py": "",
    "app/models/product.py": "",
    "app/models/order.py": "",
    "app/models/payment.py": "",
    "app/models/banners.py": "",
    "app/models/notifications.py": "",
    "app/models/downloads.py": "",
    "app/models/support.py": "",
    "app/schemas/__init__.py": "",
    "app/schemas/auth_schema.py": "",
    "app/schemas/course_schema.py": "",
    "app/schemas/product_schema.py": "",
    "app/schemas/order_schema.py": "",
    "app/routes/__init__.py": "",
    "app/routes/auth.py": "",
    "app/routes/courses.py": "",
    "app/routes/products.py": "",
    "app/routes/payments.py": "",
    "app/routes/banners.py": "",
    "app/routes/downloads.py": "",
    "app/routes/ai_chat.py": "",
    "app/routes/admin.py": "",
    "app/services/__init__.py": "",
    "app/services/razorpay_service.py": "",
    "app/services/cloudflare_service.py": "",
    "app/services/ai_service.py": "",
    "app/services/notification_service.py": "",
    "app/services/auth_service.py": "",
    "app/middleware/__init__.py": "",
    "app/middleware/auth_middleware.py": "",
    "app/middleware/rate_limit.py": "",
    "app/utils/__init__.py": "",
    "app/utils/security.py": "",
    "app/utils/helpers.py": "",
    "app/utils/validators.py": "",
    "requirements.txt": "fastapi\nuvicorn\nsqlalchemy\npsycopg2-binary\npydantic\npython-jose[cryptography]\npasslib[bcrypt]\npython-multipart\nrazorpay\nopenai\nfirebase-admin\nredis\n",
    "Dockerfile": "FROM python:3.9\nWORKDIR /code\nCOPY ./requirements.txt /code/requirements.txt\nRUN pip install --no-cache-dir --upgrade -r /code/requirements.txt\nCOPY ./app /code/app\nCMD [\"uvicorn\", \"app.main:app\", \"--host\", \"0.0.0.0\", \"--port\", \"8000\"]\n",
    "docker-compose.yml": "",
    ".env": "DATABASE_URL=postgresql://user:password@localhost/dbname\nSECRET_KEY=yoursecretkey\nALGORITHM=HS256\nACCESS_TOKEN_EXPIRE_MINUTES=30\n"
}

os.makedirs(base_dir, exist_ok=True)

for d in dirs:
    os.makedirs(os.path.join(base_dir, d), exist_ok=True)

for f, content in files.items():
    path = os.path.join(base_dir, f)
    with open(path, "w") as file:
        file.write(content)
