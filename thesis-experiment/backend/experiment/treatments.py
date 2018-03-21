from .models import Treatment, Assignment
from django.db.models import Count, Max, Q
from operator import itemgetter

def get_active_treatments():
    return Treatment.active_treatments.all()

def get_default_treatment():
    t, _ = Treatment.objects.get_or_create(name='default', defaults={'label': 'default', })
    return t

def assignment_stats():
    # Get current assignment counts
    current_assignments = Assignment.objects.order_by().values('user_id').annotate(max_id=Max('id')).values('max_id')
    counts = Treatment.objects.filter(target_assignment_ratio__gt=0).values(
        'id', 'target_assignment_ratio', 'label'
    ).annotate(count=Count('assignment', filter=Q(assignment__id__in=current_assignments), distinct=True))

    # Compute distances
    total_assignments = sum([c['count'] for c in counts])
    for c in counts:
        if total_assignments == 0:
            c.update(ratio=0)
        else:
            c.update(ratio=c['count']/total_assignments)
        c.update(ratio_distance=c['target_assignment_ratio']-c['ratio'])
        c.update(display_ratio=c['ratio']-abs(min(0, c['ratio_distance'])))
    return counts

def auto_assign_user(user):
    """Assign user to a treatment, satisfying the treatment assignment target ratios"""
    # Select treatment with highest ratio distance
    treatment = max(assignment_stats(), key=itemgetter('ratio_distance'))
    # Create new assignment
    assignment = Assignment(treatment_id=treatment['id'], user=user)
    assignment.save()
    return assignment

