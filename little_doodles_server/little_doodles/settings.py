"""
Django settings for little_doodles project.
"""
import os

from pathlib import Path

try:
    from little_doodles import local_settings
except ImportError as e:
    print(
        "Can't find the local_settings.py file!\n\n"
        "Make sure you copied it from local_settings.py.template and set appropriate values."
    )
    raise e

BASE_DIR = Path(__file__).resolve().parent.parent
SECRET_KEY = local_settings.SECRET_KEY
DEBUG = local_settings.DEBUG

ALLOWED_HOSTS = local_settings.ALLOWED_HOSTS
CSRF_TRUSTED_ORIGINS = list([
    scheme + "://" + ('*' + host if host.startswith('.') else host)
    for scheme in ["http", "https"] for host in local_settings.ALLOWED_HOSTS
])
print(CSRF_TRUSTED_ORIGINS)

# Application definition
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'game_server',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'little_doodles.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'little_doodles.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}

STATIC_URL = '/static/'

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'django.server': {
            '()': 'django.utils.log.ServerFormatter',
            'format': '[{server_time}] {message}',
            'style': '{',
        },
        'simple': { 
            'format': '[%(asctime)s] %(levelname)s [%(name)s:%(lineno)s] %(message)s' 
        }
    },
    'handlers': {
        'file':     { 
            'class': 'logging.FileHandler', 'filename': 'portal.log', 'formatter': 'simple' 
        },
        'django.server': {
            'level': 'INFO', 'class': 'logging.StreamHandler', 'formatter': 'django.server',
        },
    },
    'loggers': {
        'django.server': {
            'handlers': ['file', 'django.server'], 'level': 'INFO', 'propagate': False, 
        },
        'game_server': {
            'handlers': ['file', 'django.server'], 'level': 'DEBUG', 'propagate': True 
        },
    },
}

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_L10N = True
USE_TZ = True
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
