"""
    game_server.urls
    ~~~~~~~~~~~~~~~~
"""
from django.urls import path

from .views import EntityCreateView, EntityView, UserCreateView, UserAuthView

app_name = "game_server"

urlpatterns = [
    path("entity/add/", EntityCreateView.as_view(), name="entity-add"),
    path("entity/<uuid>/", EntityView.as_view(), name="entity"),
    path("user/add/", UserCreateView.as_view(), name="user-add"),
    path("user/auth/", UserAuthView.as_view(), name="user-auth"),
]
