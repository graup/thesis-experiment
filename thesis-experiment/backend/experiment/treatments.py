from .models import Treatment

def get_active_treatments():
    return Treatment.active_treatments.all()

