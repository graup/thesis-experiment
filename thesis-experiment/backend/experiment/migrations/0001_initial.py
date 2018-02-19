# Generated by Django 2.0.1 on 2018-02-19 04:42

from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion
import django.db.models.manager


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='Assignment',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('assigned_date', models.DateField(auto_now_add=True)),
            ],
        ),
        migrations.CreateModel(
            name='GcosResult',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('completed_date', models.DateField(auto_now_add=True)),
                ('score_autonomy', models.IntegerField()),
                ('score_control', models.IntegerField()),
                ('score_impersonal', models.IntegerField()),
                ('score_order', models.CharField(max_length=3)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Treatment',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.SlugField(unique=True)),
                ('label', models.CharField(max_length=50)),
                ('is_active', models.BooleanField(default=True)),
            ],
            options={
                'ordering': ('name',),
            },
            managers=[
                ('active_treatments', django.db.models.manager.Manager()),
            ],
        ),
        migrations.AddField(
            model_name='assignment',
            name='treatment',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='experiment.Treatment'),
        ),
        migrations.AddField(
            model_name='assignment',
            name='user',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL),
        ),
    ]
