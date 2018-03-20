from django.db import models
from django.conf import settings
from django.utils.translation import gettext_lazy as _


class ActiveManager(models.Manager):
    def get_queryset(self):
        return super().get_queryset().filter(is_active=True)


class Treatment(models.Model):
    name = models.SlugField(unique=True)
    label = models.CharField(max_length=50)
    is_active = models.BooleanField(default=True)

    objects = models.Manager()
    active_treatments = ActiveManager()

    def __str__(self):
        return self.label

    class Meta:
        ordering = ('name',)


class Assignment(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    treatment = models.ForeignKey(Treatment, on_delete=models.CASCADE)
    assigned_date = models.DateTimeField(auto_now_add=True)

    __treatment = None

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.__treatment_id = self.treatment_id

    def __str__(self):
        return '%s - %s' % (self.user, self.treatment)

    def save(self, *args, **kwargs):
        if self.treatment_id != self.__treatment_id:
            # Force creation of new item
            self.pk = None
        super().save(*args, **kwargs)


class GcosResult(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    completed_date = models.DateField(auto_now_add=True)
    score_autonomy = models.IntegerField()
    score_control = models.IntegerField()
    score_impersonal = models.IntegerField()
    score_order = models.CharField(max_length=3)

    @property
    def scores(self):
        return {
            'A': self.score_autonomy,
            'C': self.score_control,
            'I': self.score_impersonal
        }
    
    def _calculate_score_order(self):
        scores_sorted = sorted(self.scores.items(), key=lambda item: item[1])[::-1]
        return ''.join([item[0] for item in test_scores_sorted])

    def save(self, *args, **kwargs):
        self.score_order = self._calculate_score_order()
        super().save(*args, **kwargs)

    def __str__(self):
        return 'A %d, C %d, I %d' % (self.score_autonomy, self.score_control, self.score_impersonal)