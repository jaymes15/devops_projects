from django.urls import path

from . import views

app_name = "health_check"

urlpatterns = [
    path("", views.health_check, name="health_check"),
]
