from rest_framework import permissions
from rest_framework.generics import CreateAPIView
from django.contrib.auth import get_user_model
from django.views.generic import TemplateView
import oauth2_provider.views
from oauth2_provider.models import Application

from .serializers import UserSerializer


class TokenView(oauth2_provider.views.TokenView):
    def create_token_response(self, request):
        post_data = request.POST.copy()
        email = post_data.pop('email', None)
        if email:
            username = get_user_model().objects.filter(email=email[0]).values_list('username', flat=True).last()
            post_data['username'] = username
            request.POST = post_data
        return super(TokenView, self).create_token_response(request)

class OAuthSuccessView(TemplateView):
    template_name = "oauth/success.html"

class CreateUserView(CreateAPIView):
    model = get_user_model()
    permission_classes = [
        permissions.AllowAny # Or anon users can't register
    ]
    serializer_class = UserSerializer