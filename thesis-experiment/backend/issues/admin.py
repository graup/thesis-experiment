from django.contrib import admin
from django.db.models.functions import Now
from .models import Category, Issue, Comment, Tag

admin.site.register(Category, admin.ModelAdmin)
admin.site.register(Tag, admin.ModelAdmin)

class CommentAdmin(admin.ModelAdmin):
    model = Comment
    list_display = ('issue', 'author', 'text', 'created_date', 'deleted_date',)
    actions = ['soft_delete_comment']

    def soft_delete_comment(self, request, queryset):
        rows_updated = queryset.update(deleted_date=Now())
        self.message_user(request, "%d comments successfully soft-deleted." % rows_updated)
    soft_delete_comment.short_description = "Soft-delete comment"

admin.site.register(Comment, CommentAdmin)


class IssueAdmin(admin.ModelAdmin):
    model = Issue
    list_display = ('title', 'created_date', 'author',)
admin.site.register(Issue, IssueAdmin)
