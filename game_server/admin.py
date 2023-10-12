from django.contrib import admin

from .models import Entity


class ToggleActiveAdminMixin:
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if "set_active" not in self.actions:
            self.actions = self.actions + ("set_active",)
        if "set_inactive" not in self.actions:
            self.actions = self.actions + ("set_inactive",)

    def set_active(self, request, queryset):
        queryset.update(active=True)

    set_active.short_description = "Mark selected items as active"

    def set_inactive(self, request, queryset):
        queryset.update(active=False)

    set_inactive.short_description = "Mark selected items as inactive"


@admin.register(Entity)
class EntityAdmin(ToggleActiveAdminMixin, admin.ModelAdmin):
    list_display = ("uuid", "name", "kind", "player", "active", "created", "changed")
    list_filter = ("created", "changed", "active")
    search_fields = ("name", "kind", "player__username", "data")
    readonly_fields = ("created", "changed")
