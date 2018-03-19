from rest_framework import viewsets, filters, permissions
from rest_framework.decorators import list_route, detail_route
from rest_framework.response import Response
from rest_framework.exceptions import NotAuthenticated
from rest_framework.permissions import IsAuthenticated

from .serializers import *
from .models import Issue
from rest_framework.pagination import LimitOffsetPagination
from django.contrib.auth.models import User
from django.db.models import Count, Q

class IsAuthorOrReadOnly(permissions.BasePermission):
    """
    Object-level permission to only allow owners of an object to edit it.
    """
    def has_object_permission(self, request, view, obj):
        if request.method in permissions.SAFE_METHODS:
            return True

        # Instance must have an attribute named `owner`.
        return obj.author == request.user

class LargeResultsSetPagination(LimitOffsetPagination):
    default_limit = 100
    max_limit = 1000

class CommentViewSet(viewsets.ModelViewSet):
    queryset = Comment.objects
    serializer_class = CommentSerializer
    pagination_class = LargeResultsSetPagination
    permission_classes = (IsAuthenticated,)

class IssueViewSet(viewsets.ModelViewSet):
    queryset = Issue.objects
    serializer_class = IssueSerializer
    filter_backends = (filters.SearchFilter,)
    search_fields = ('title',)
    pagination_class = LargeResultsSetPagination
    lookup_field = 'slug'
    permission_classes = (IsAuthorOrReadOnly,)

    def get_queryset(self):
        qs = self.queryset
        if self.request.method == "POST":
            return qs
        # Add like count
        qs = qs.annotate(like_count=Count('tag', filter=Q(tag__kind=0)))
        # Add comment count
        qs = qs.annotate(comment_count=Count('comment'))
        # Add if user has liked this issue
        if self.request.user and self.request.user.is_authenticated:
            qs = qs.annotate(user_liked=Count('tag', filter=Q(tag__kind=0) & Q(tag__author=self.request.user)))
        return qs

    @detail_route(permission_classes=[IsAuthenticated,], url_name='comments')
    def comments(self, request, **kwargs):
        self.kwargs = kwargs
        if not self.request.user or not self.request.user.is_authenticated:
            raise NotAuthenticated()

        obj = self.get_object()
        context = {
            'request': request
        }
        serializer = CommentSerializer(obj.comment_set, many=True, context=context)
        return Response(serializer.data)
    
    @detail_route(methods=['post'], permission_classes=[IsAuthenticated,])
    def like(self, request, **kwargs):
        self.kwargs = kwargs
        if not self.request.user or not self.request.user.is_authenticated:
            raise NotAuthenticated()

        obj = self.get_object()
        obj.set_user_liked(self.request.user, self.request.data['liked'])
        context = {
            'request': request
        }
        serializer = IssueSerializer(obj, context=context)
        return Response(serializer.data)


class UserViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    @list_route()
    def me(self, request, pk=None):
        if not self.request.user or not self.request.user.is_authenticated:
            raise NotAuthenticated()

        obj = User.objects.get(pk=request.user.id)
        context = {
            'request': request
        }
        serializer = UserSerializer(obj, context=context)
        return Response(serializer.data)