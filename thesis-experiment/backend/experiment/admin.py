from django.contrib import admin
from .models import Treatment, Assignment

admin.site.register(Treatment, admin.ModelAdmin)
admin.site.register(Assignment, admin.ModelAdmin)

