# Generated by Django 2.0.1 on 2018-03-21 12:56

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('issues', '0003_tag_author'),
    ]

    operations = [
        migrations.AddField(
            model_name='tag',
            name='data',
            field=models.TextField(blank=True, null=True),
        ),
    ]