from django.urls import path
from . import views

app_name = 'item'

urlpatterns = [
    path('new/', views.new, name="new"),
    path('<int:pk>', views.detail, name='detail'),
    path('delete/<int:pk>', views.delete_item, name='delete_item'),
]
