from django.contrib import admin
from .models import Treatment, Assignment

admin.site.register(Treatment, admin.ModelAdmin)

class AssignmentAdmin(admin.ModelAdmin):
    model = Assignment
    list_display = ('user', 'treatment', 'assigned_date',)
admin.site.register(Assignment, AssignmentAdmin)
