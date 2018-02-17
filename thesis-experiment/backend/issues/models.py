from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _
from django.utils.text import slugify
from autoslug import AutoSlugField


class Category(models.Model):
    label = models.CharField(max_length=200)
    slug = AutoSlugField(populate_from='label', unique=True)

    def __str__(self):
        return self.label

    class Meta:
        ordering = ('slug',)
        verbose_name = _("category")
        verbose_name_plural = _("categories")


class Issue(models.Model):
    "A user-generated issue"
    title = models.CharField(max_length=250)
    text = models.TextField()
    created_date = models.DateTimeField(_('date created'), auto_now_add=True)
    modified_date = models.DateTimeField(_('date modified'), auto_now=True)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    categories = models.ManyToManyField(Category)
    slug = AutoSlugField(populate_from='title', unique=True)

    def __str__(self):
        return self.title

    class Meta:
        ordering = ('-created_date',)
        verbose_name = _("issue")


class Comment(models.Model):
    issue = models.ForeignKey(Issue, on_delete=models.CASCADE)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_date = models.DateTimeField(_('date created'), auto_now_add=True)
    deleted_date = models.DateTimeField(_('date deleted'), blank=True, null=True)
    text = models.TextField()

    class Meta:
        ordering = ('-created_date',)
        verbose_name = _("comment")