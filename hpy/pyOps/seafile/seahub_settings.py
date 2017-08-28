# -*- coding: utf-8 -*-
SECRET_KEY = "==bf2y=mh$b+ny*3yt*r#=xzf+1%_5irr=h$2s3c62j3-ly4w6"

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'seahub-db',
        'USER': 'seafile',
        'PASSWORD': 'deviskaifa',
        'HOST': '127.0.0.1',
        'PORT': '3306'
    }
}

#CACHES = {
#    'default': {
#        'BACKEND': 'django_pylibmc.memcached.PyLibMCCache',
#        'LOCATION': '127.0.0.1:11211',
#    }
#}

EMAIL_USE_SSL = True
EMAIL_HOST = 'smtp.qq.com'
EMAIL_HOST_USER = '734615430@qq.com'
EMAIL_HOST_PASSWORD = 'rapjkyvmvkfybedh'
EMAIL_PORT = '465'
DEFAULT_FROM_EMAIL = EMAIL_HOST_USER
SERVER_EMAIL = EMAIL_HOST_USER
