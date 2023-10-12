"""
    game_server.models
    ~~~~~~~~~~~~~~~~~~
"""
import logging
import uuid

from django.contrib.auth import get_user_model
from django.db import models


logger = logging.getLogger("game_server")


class Entity(models.Model):
    created = models.DateTimeField(auto_now_add=True)
    changed = models.DateTimeField(auto_now=True)
    active = models.BooleanField(blank=True, default=True)
    uuid = models.UUIDField(blank=True, default=uuid.uuid4, unique=True, db_index=True)
    player = models.ForeignKey(get_user_model(), on_delete=models.CASCADE)
    kind = models.CharField(max_length=1024, db_index=True)
    name = models.CharField(max_length=1024, db_index=True)
    data = models.JSONField(blank=True, default=dict)

    def __str__(self):
        return f"{self.name}"
