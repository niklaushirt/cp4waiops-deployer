from django.urls import path

from . import views

urlpatterns = [
    path('doc', views.doc, name='doc'),
    path('about', views.about, name='about'),
    path('', views.index, name='index'),
    path('webhook', views.webhook, name='webhook'),
    path('webhookIterate', views.webhookIterate, name='webhookIterate'),
    path('webhookSingle', views.webhookSingle, name='webhookSingle'),
    path('webhookDebug', views.webhookDebug, name='webhookDebug')
]