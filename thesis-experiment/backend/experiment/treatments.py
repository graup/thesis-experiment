from .models import Treatment

def get_active_treatments():
    return Treatment.active_treatments.all()

def get_default_treatment():
    print(dir(Treatment))
    t, _ = Treatment.objects.get_or_create(name='default', defaults={'label': 'default', })
    return t
