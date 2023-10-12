"""
    game_server.views
    ~~~~~~~~~~~~~~~~~
"""
from django.contrib.auth import login
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.mixins import LoginRequiredMixin
from django.forms import ModelForm
from django.http import JsonResponse
from django.middleware.csrf import get_token
from django.views.generic import View

from .models import Entity


def failure_response(errors):
    return JsonResponse({"result": "failure", "errors": errors})


class JsonFormView(View):
    def get(self, request):
        return JsonResponse({"csrf_token": get_token(request)})

    def validate_form(self, form):
        if form.is_valid():
            return True, JsonResponse({"result": "success"})
        return False, failure_response(form.errors.get_json_data())


class UserCreateView(JsonFormView):
    def post(self, request):
        form = UserCreationForm(request.POST)
        result, response = self.validate_form(form)
        if result:
            login(request, form.save())
        return response


class UserAuthView(JsonFormView):
    def post(self, request):
        form = AuthenticationForm(request.POST)
        result, response = self.validate_form(form)
        if result:
            login(request, form.get_user())
        return response


class EntityForm(ModelForm):
    class Meta:
        model = Entity
        fields = ["kind", "name", "data"]


class EntityCreateView(LoginRequiredMixin, JsonFormView):
    def post(self, request):
        form = EntityForm(request.POST)
        result, response = self.validate_form(form)
        if result:
            entity = form.save(commit=False)
            entity.player = request.user
            entity.save()
        return response


class EntityView(LoginRequiredMixin, JsonFormView):
    def get(self, request, uuid):
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
        try:
            entity = Entity.objects.get(uuid=uuid, active=True)
        except Entity.DoesNotExist:
            return failure_response("Invalid UUID")

        if request.user != entity.player:
            return failure_response("Change Permission Denied")

        form = EntityForm(request.POST, instance=entity)
        result, response = self.validate_form(form)
        if result:
            form.save()
        return response


class EntitySearchView(LoginRequiredMixin, View):
    def get(self, request):
        return JsonResponse({"csrf_token": get_token(request)})

    def post(self, request):
        entities = Entity.objects.filter(active=True)
        try:
            entities.filter(**request.GET)
        except TypeError:
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
