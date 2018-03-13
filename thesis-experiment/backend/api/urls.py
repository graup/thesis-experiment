from django.conf.urls import url, include
from . import views
from rest_framework.routers import DefaultRouter
import oauth2_provider.views as oauth2_views
from issues.viewsets import IssueViewSet, UserViewSet, CommentViewSet

router = DefaultRouter()
router.register(r'issues', IssueViewSet)
router.register(r'users', UserViewSet)
router.register(r'comments', CommentViewSet)

urlpatterns = [
    url(r'^auth/signup/?$', views.CreateUserView.as_view(), name='rest_register'),
    url(r'^auth/login/?$', views.TokenView.as_view()),
    url(r'^auth/success/', views.OAuthSuccessView.as_view()),
    url(r'^auth/', include('oauth2_provider.urls', namespace='oauth2_provider')),
    url('', include(router.urls)),
]
