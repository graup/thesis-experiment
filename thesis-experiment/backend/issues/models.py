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

    def get_like_count(self):
        return self.tag_set.filter(kind=0).count()

    def set_user_liked(self, user, liked):
        likes = self.tag_set.filter(kind=0, author=user).all()
        if liked and not likes:
            tag = Tag(issue=self, author=user, kind=0)
            tag.save()
        if not liked and likes:
            Tag.objects.filter(issue=self, author=user, kind=0).delete()
        self.user_liked = liked

    class Meta:
        ordering = ('-created_date',)
        verbose_name = _("issue")


class Tag(models.Model):
    KIND_CHOICES = (
        (0, 'like'),
        (1, 'flag'),
    )

    issue = models.ForeignKey(Issue, on_delete=models.CASCADE)
    kind = models.IntegerField(default=0, choices=KIND_CHOICES)
    value = models.IntegerField(default=1)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    def __str__(self):
        return '<%s> %ss <%s>' % (self.author, self.get_kind_display(), self.issue)

class Comment(models.Model):
    issue = models.ForeignKey(Issue, on_delete=models.CASCADE)
    author = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    created_date = models.DateTimeField(_('date created'), auto_now_add=True)
    deleted_date = models.DateTimeField(_('date deleted'), blank=True, null=True)
    text = models.TextField()

    class Meta:
        ordering = ('-created_date',)
        verbose_name = _("comment")

    def __str__(self):
        return self.text[:50]
