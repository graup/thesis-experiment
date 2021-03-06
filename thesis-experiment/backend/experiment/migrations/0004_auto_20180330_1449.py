# Generated by Django 2.0.1 on 2018-03-30 14:49

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('experiment', '0003_treatment_target_assignment_ratio'),
    ]

    operations = [
        migrations.CreateModel(
            name='ClassificationResult',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('completed_date', models.DateField(auto_now_add=True)),
                ('score_autonomy', models.IntegerField(default=0)),
                ('score_impersonal', models.IntegerField(default=0)),
                ('score_control', models.IntegerField(default=0)),
                ('score_amotivation', models.IntegerField(default=0)),
                ('calculated_group', models.CharField(blank=True, max_length=10, null=True)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.AddField(
            model_name='assignment',
            name='group',
            field=models.CharField(blank=True, max_length=10, null=True),
        ),
    ]
