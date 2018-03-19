from rest_framework import serializers
from .models import Treatment

class TreatmentSerializer(serializers.HyperlinkedModelSerializer):
    class Meta:
        model = Treatment
        fields = ('name', 'label',)