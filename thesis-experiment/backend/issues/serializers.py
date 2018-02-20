from django.contrib.auth.models import User
from rest_framework import serializers
from .models import Issue, Category
from api.serializers import UserSerializer


class UserSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = User
        fields = ('url', 'username', 'get_short_name', 'date_joined',)


class IssueSerializer(serializers.HyperlinkedModelSerializer):
    categories = serializers.PrimaryKeyRelatedField(many=True, queryset=Category.objects)
    author = UserSerializer(read_only=True, default=serializers.CurrentUserDefault())

    class Meta:
        model = Issue
        fields = ('url', 'id', 'title', 'text', 'created_date', 'modified_date', 'author', 'categories', 'slug',)
        lookup_field = 'slug'
        extra_kwargs = {
            'url': {'lookup_field': 'slug'}
        }

