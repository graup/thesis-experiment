from django.contrib import admin
from django.urls import path, include
from .views import AssignmentUpdateView
from django.contrib.admin.views.decorators import staff_member_required


urlpatterns = [
    path('admin/treatment-assignments', staff_member_required(AssignmentUpdateView.as_view()), name='treatment-assignments'),
]
