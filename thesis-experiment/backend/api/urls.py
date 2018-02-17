from django.conf.urls import url, include
from . import views
from rest_framework.routers import DefaultRouter
import oauth2_provider.views as oauth2_views

"""
router = DefaultRouter()
router.register(r'areas', AreaViewSet)
router.register(r'people', PersonViewSet)
router.register(r'voting-districts', VotingDistrictViewSet)
router.register(r'promises', PromiseViewSet)
router.register(r'news', ArticleViewSet)
router.register(r'budget-programs', BudgetProgramViewSet)

"""
urlpatterns = [
    #url(r'^api/', include(router.urls)),

    url(r'^auth/signup/?$', views.CreateUserView.as_view(), name='rest_register'),
    url(r'^auth/login/?$', views.TokenView.as_view()),
    url(r'^auth/success/', views.OAuthSuccessView.as_view()),
    url(r'^auth/', include('oauth2_provider.urls', namespace='oauth2_provider')),
]
