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
    like_count = serializers.IntegerField()
    user_liked = serializers.BooleanField(default=False)

    class Meta:
        model = Issue
        fields = ('url', 'id', 'title', 'text', 'created_date', 'modified_date', 'author', 'categories', 'slug', 'like_count', 'user_liked')
        lookup_field = 'slug'
        extra_kwargs = {
            'url': {'lookup_field': 'slug'}
        }

