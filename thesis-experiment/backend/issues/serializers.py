from django.contrib.auth.models import User
from rest_framework import serializers
from .models import Issue, Category, Comment
from api.serializers import UserSerializer
from experiment.treatments import get_default_treatment
from experiment.serializers import TreatmentSerializer


class UserSerializer(serializers.HyperlinkedModelSerializer):
    active_treatment = serializers.SerializerMethodField()

    def get_active_treatment(self, obj):
        try:
            t = obj.assignment_set.order_by("-assigned_date").all()[0].treatment
        except IndexError:
            t = get_default_treatment()
        return TreatmentSerializer(t).data

    class Meta:
        model = User
        fields = ('url', 'username', 'get_short_name', 'active_treatment',)


class CommentSerializer(serializers.HyperlinkedModelSerializer):
    author = UserSerializer(read_only=True, default=serializers.CurrentUserDefault())

    class Meta:
        model = Comment
        fields = ('url', 'id', 'text', 'created_date', 'author', )


class IssueSerializer(serializers.HyperlinkedModelSerializer):
    categories = serializers.PrimaryKeyRelatedField(many=True, queryset=Category.objects)
    author = UserSerializer(read_only=True, default=serializers.CurrentUserDefault())
    like_count = serializers.IntegerField(read_only=True)
    comment_count = serializers.IntegerField(read_only=True)
    user_liked = serializers.BooleanField(read_only=True)
    comments_url = serializers.HyperlinkedIdentityField(read_only=True, view_name='issue-comments', lookup_field='slug', )

    class Meta:
        model = Issue
        fields = (
            'url', 'id',
            'title', 'text',
            'created_date', 'modified_date',
            'author',
            'categories', 'slug',
            'like_count', 'comment_count',
            'user_liked',
            'comments_url',
        )
        lookup_field = 'slug'
        extra_kwargs = {
            'url': {'lookup_field': 'slug'}
        }
        read_only_fields = ('slug', 'user_liked',)
