import os

from .settings import *

SECRET_KEY = os.environ["DJANGO_SECRET_KEY"]
DEBUG = False
ALLOWED_HOSTS = os.environ["DJANGO_ALLOWED_HOSTS"].split(",")

DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": os.environ["POSTGRES_DB"],
        "USER": os.environ["POSTGRES_USER"],
        "PASSWORD": os.environ["POSTGRES_PASSWORD"],
        "HOST": "db",
        "PORT": "5432",
    }
}

LANGUAGE_CODE = "pl"
TIME_ZONE = "Europe/Warsaw"
STATIC_URL = "/static/"
STATIC_ROOT = "/srv/static"

# Gmail SMTP. Credentials are supplied through the deployment environment.
EMAIL_BACKEND = "django.core.mail.backends.smtp.EmailBackend"
EMAIL_HOST = os.environ.get("EMAIL_HOST", "smtp.gmail.com")
EMAIL_PORT = int(os.environ.get("EMAIL_PORT", "587"))
EMAIL_HOST_USER = os.environ.get("EMAIL_HOST_USER", "")
EMAIL_HOST_PASSWORD = os.environ.get("EMAIL_HOST_PASSWORD", "")
EMAIL_USE_TLS = True
EMAIL_USE_SSL = False
EMAIL_TIMEOUT = 20
DEFAULT_FROM_EMAIL = (
    f"Portal WZ <{EMAIL_HOST_USER}>" if EMAIL_HOST_USER else ""
)

# Private persistent directory for the additional case record.
CASE_DATA_ROOT = os.environ["CASE_DATA_ROOT"]
