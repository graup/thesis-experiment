from rest_framework import viewsets, filters, permissions
from rest_framework.decorators import list_route
from rest_framework.response import Response
from rest_framework.exceptions import NotAuthenticated

from .serializers import *
from .models import Issue
from rest_framework.pagination import LimitOffsetPagination
from django.contrib.auth.models import User

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

class IssueViewSet(viewsets.ModelViewSet):
    queryset = Issue.objects.all()
    serializer_class = IssueSerializer
    filter_backends = (filters.SearchFilter,)
    search_fields = ('title',)
    pagination_class = LargeResultsSetPagination
    lookup_field = 'slug'
    permission_classes = (IsAuthorOrReadOnly,)


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
