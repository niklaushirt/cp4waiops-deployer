from django.urls import path

from . import views

urlpatterns = [
    path('health', views.health, name='health'),
    path('loginui', views.loginui, name='loginui'),
    path('login', views.login, name='login'),
    path('doc', views.doc, name='doc'),
    path('config', views.config, name='config'),
    path('apps', views.apps, name='apps'),
    path('apps_system', views.apps_system, name='apps_system'),
    path('apps_additional', views.apps_additional, name='apps_additional'),
    path('about', views.about, name='about'),
    path('', views.index, name='index'),
    path('injectLogsREST', views.injectLogsREST, name='injectLogsREST'),
    path('injectEventsREST', views.injectEventsREST, name='injectEventsREST'),
    path('injectMetricsREST', views.injectMetricsREST, name='injectMetricsREST'),
    path('injectAllREST', views.injectAllREST, name='injectAllREST'),
    path('injectAllFanREST', views.injectAllFanREST, name='injectAllFanREST'),
    path('clearAllREST', views.clearAllREST, name='clearAllREST'),
    path('clearEventsREST', views.clearEventsREST, name='clearEventsREST'),
    path('clearStoriesREST', views.clearStoriesREST, name='clearStoriesREST'),
]
