# Generated by Django 2.0.1 on 2018-03-07 06:23

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('issues', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Tag',
            fields=[
                ('id', models.AutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('kind', models.IntegerField(choices=[(0, 'like'), (1, 'flag')], default=0)),
                ('value', models.IntegerField(default=1)),
                ('issue', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='issues.Issue')),
            ],
        ),
    ]