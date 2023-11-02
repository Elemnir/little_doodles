"""
    game_server.views
    ~~~~~~~~~~~~~~~~~
"""
import json

from django.contrib.auth import login
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.exceptions import FieldError
from django.forms import ModelForm
from django.http import JsonResponse
from django.middleware.csrf import get_token
from django.views.generic import View

from .models import Entity


def failure_response(errors):
    """Returns a JsonResponse formatted to inform the client of an error."""
    return JsonResponse({"result": "failure", "errors": errors})


class JsonFormView(View):
    """Base class that wraps some repetitive logic for JSON form views."""
    def get(self, request):
        """GET request logic just returns the token for CSRF protection."""
        return JsonResponse({"csrf_token": get_token(request)})

    def validate_form(self, form):
        """Return if the given form was valid along with a response."""
        if form.is_valid():
            return True, JsonResponse({"result": "success"})
        return False, failure_response(form.errors.get_json_data())


class UserCreateView(JsonFormView):
    """Simple User Creation View"""
    def post(self, request):
        try:
            form = UserCreationForm(json.loads(request.body))
        except json.JSONDecodeError:
            return failure_response("Request body was not valid JSON")

        result, response = self.validate_form(form)
        if result:
            login(request, form.save())
        return response


class UserAuthView(JsonFormView):
    """Simple User Authentication View"""
    def post(self, request):
        try:
            form = AuthenticationForm(data=json.loads(request.body))
        except json.JSONDecodeError:
            return failure_response("Request body was not valid JSON")

        result, response = self.validate_form(form)
        if result:
            login(request, form.get_user())
        return response


class EntityForm(ModelForm):
    """Basic ModelForm for validating Entity information from an end user."""
    class Meta:
        model = Entity
        fields = ["kind", "name", "data"]


class EntityCreateView(LoginRequiredMixin, JsonFormView):
    def post(self, request):
        """Entity creation view."""
        try:
            form = EntityForm(json.loads(request.body))
        except json.JSONDecodeError:
            return failure_response("Request body was not valid JSON")

        result, response = self.validate_form(form)
        if result:
            entity = form.save(commit=False)
            entity.player = request.user
            entity.save()
        return response


class EntityView(LoginRequiredMixin, JsonFormView):
    def get(self, request, uuid):
        """Entity detail view."""
        try:
            entity = Entity.objects.get(uuid=uuid, active=True)
        except Entity.DoesNotExist:
            return failure_response("Invalid UUID")
        return JsonResponse({
            "csrf_token": get_token(request),
            "entity": {
                "uuid": entity.uuid,
                "name": entity.name,
                "kind": entity.kind,
                "player": entity.player.username,
                "data": entity.data,
            },
        })

    def post(self, request, uuid):
        """Entity edit/change view."""
        try:
            entity = Entity.objects.get(uuid=uuid, active=True)
        except Entity.DoesNotExist:
            return failure_response("Invalid UUID")

        if request.user != entity.player:
            return failure_response("Change Permission Denied")

        try:
            form = EntityForm(json.loads(request.body), instance=entity)
        except json.JSONDecodeError:
            return failure_response("Request body was not valid JSON")

        result, response = self.validate_form(form)
        if result:
            form.save()
        return response


class EntitySearchView(LoginRequiredMixin, View):
    def get(self, request):
        """Search through the Entities using arbitrary filters. Any GET
        parameters included in the URL will be passed to
        ``Entity.objects.filter()``. In the returned JSON object, there will
        be an "entities" key whose value is a list of any active Entity objects
        matching the query parameters, which could be empty.
        """
        entities = Entity.objects.filter(active=True)
        try:
            entities.filter(**request.GET)
        except FieldError:
            return failure_response("Bad Query")
        return JsonResponse({
            "result": "success",
            "entities": [
                {
                    "uuid": e.uuid,
                    "name": e.name,
                    "kind": e.kind,
                    "player": e.player.username,
                    "data": e.data
                }
                for e in entities
            ]
        })
