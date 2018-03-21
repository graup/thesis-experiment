from django.contrib import admin
from .models import Treatment, Assignment

class TreatmentAdmin(admin.ModelAdmin):
    model = Treatment
    list_display = ('name', 'label', 'is_active', 'target_assignment_ratio',)
admin.site.register(Treatment, TreatmentAdmin)

class AssignmentAdmin(admin.ModelAdmin):
    model = Assignment
    list_display = ('user', 'treatment', 'assigned_date',)
admin.site.register(Assignment, AssignmentAdmin)
