from django.views.generic.base import TemplateView
from django.urls import reverse
from django import forms
from django.http import HttpResponseRedirect
from .models import Assignment, Treatment
from .treatments import get_default_treatment, auto_assign_user, assignment_stats, get_auto_treatment
from django.contrib.auth.models import User
from django.db.models import Max
from django.contrib import admin

class AssignmentForm(forms.ModelForm):
    treatment = forms.ModelChoiceField(queryset=Treatment.objects, widget=forms.RadioSelect, required=False)
    auto_assign = forms.BooleanField(required=False)
    group = forms.ChoiceField(choices=[(None, '(None)')]+[(g, g) for g in Assignment.GROUPS], required=False)

    class Meta:
        model = Assignment
        fields = ['user', 'group', 'treatment', 'auto_assign']

class AssignmentUpdateView(TemplateView):
    model = Assignment
    form_class = AssignmentForm
    template_name = "experiment/AssignmentUpdateView.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        # Get latest assignment for each user
        qs = Assignment.objects.filter(pk__in=
            Assignment.objects.order_by().values('user_id').annotate(
                max_id=Max('id')
            ).values('max_id')
        ).order_by('treatment', 'user')
        # Get unassigned users
        unassigned_users = User.objects.exclude(pk__in=qs.values('user_id')).values('id', 'username')
        initials = [{'user': u['id']} for u in unassigned_users]

        # Generate formset
        AssignmentFormSet = forms.modelformset_factory(Assignment, form=AssignmentForm, extra=len(initials))
        if self.request.POST:
            context['formset'] = AssignmentFormSet(self.request.POST, queryset=qs, initial=initials)
        else:
            context['formset'] = AssignmentFormSet(queryset=qs, initial=initials)
        # Add Django Admin context
        context.update(admin.site.each_context(self.request))
        # Add stats
        stats = assignment_stats()
        context.update(
            stats=stats,
            next_assignments=[get_auto_treatment(g) for g in Assignment.GROUPS],
            total_n=sum([t['count'] for t in stats])
        )
        return context

    def post(self, form):
        context = self.get_context_data()
        formset = context['formset']
        if formset.is_valid():
            for form in formset:
                if form.cleaned_data.get('auto_assign', False):
                    auto_assign_user(form.cleaned_data['user'], form.cleaned_data['group'])
                elif form.cleaned_data.get('treatment', False):
                    form.save()
            return HttpResponseRedirect(self.get_success_url())
        else:
            return self.render_to_response(self.get_context_data())

    def get_success_url(self):
        return reverse('treatment-assignments')