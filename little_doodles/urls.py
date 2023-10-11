"""
    little_doodles.urls
    ~~~~~~~~~~~~~~~~~~~

    Core URL Configuration
"""
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('game/', include('game_server.urls')),
]
