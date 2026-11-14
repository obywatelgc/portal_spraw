from django.contrib import admin
from django.http import HttpResponse
from django.urls import path


def home(request):
    return HttpResponse(
        "<!doctype html><html lang='pl'><meta charset='utf-8'>"
        "<title>Portal WZ</title><main>"
        "<h1>Portal warunków zabudowy</h1>"
        "<p>Lokalna wersja testowa.</p>"
        "<p><a href='/admin/'>Panel pracownika</a></p>"
        "</main></html>"
    )


urlpatterns = [
    path("", home, name="home"),
    path("admin/", admin.site.urls),
]
