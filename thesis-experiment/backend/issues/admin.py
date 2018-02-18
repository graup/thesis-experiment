from django.contrib import admin
from .models import Category, Issue, Comment

admin.site.register(Category, admin.ModelAdmin)
admin.site.register(Comment, admin.ModelAdmin)

class IssueAdmin(admin.ModelAdmin):
    model = Issue
    list_display = ('title', 'created_date', 'author',)
admin.site.register(Issue, IssueAdmin)
