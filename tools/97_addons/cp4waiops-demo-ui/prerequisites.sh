# https://docs.djangoproject.com/en/4.0/intro/install/



python -m pip install Django

django-admin startproject demoui

cd demoui


python manage.py runserver

pip install confluent-kafka



python manage.py runserver



oc expose svc waiops-demo-ui-python-service -n cp4waiops  --name test1
