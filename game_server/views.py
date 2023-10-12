"""
    game_server.views
    ~~~~~~~~~~~~~~~~~
"""
from django.contrib.auth import login
from django.contrib.auth.forms import UserCreationForm, AuthenticationForm
from django.contrib.auth.mixins import LoginRequiredMixin
from django.forms import ModelForm
from django.http import HttpResponseForbidden, JsonResponse
from django.middleware.csrf import get_token
from django.shortcuts import get_object_or_404
from django.views.generic import View

from .models import Entity


class JsonFormView(View):
    def get(self, request):
        return JsonResponse({"csrf_token": get_token(request)})

    def validate_form(self, form):
        if form.is_valid():
            return True, JsonResponse({"result": "success"})
        return False, JsonResponse({
            "result": "failure",
            "errors": form.errors.get_json_data()
        })


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
        entity = get_object_or_404(Entity, uuid=uuid)
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
        entity = get_object_or_404(Entity, uuid=uuid, active=True)
        if request.user != entity.player:
            return HttpResponseForbidden

        form = EntityForm(request.POST, instance=entity)
        result, response = self.validate_form(form)
        if result:
            form.save()
        return response
