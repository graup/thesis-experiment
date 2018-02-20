import Vue from 'vue';
import Router from 'vue-router';
import Start from '@/components/pages/Start';
import Login from '@/components/pages/Login';
import Signup from '@/components/pages/Signup';
import Feed from '@/components/pages/Feed';
import IssueDetails from '@/components/pages/IssueDetails';
import NewIssue from '@/components/pages/NewIssue';

Vue.use(Router);

export default new Router({
  scrollBehavior(to, from, savedPosition) {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (savedPosition) {
          resolve(savedPosition);
        }
        resolve({ x: 0, y: 0 });
      }, 550);
    });
  },
  routes: [
    { path: '/', component: Start },
    { path: '/login', component: Login, meta: { unauth: true } },
    { path: '/signup', component: Signup, meta: { unauth: true } },
    { path: '/feed', component: Feed, meta: { auth: true } },
    { path: '/issues/new', name: 'new-issue', component: NewIssue, meta: { auth: true } },
    {
      path: '/issues/:slug',
      name: 'issue-detail',
      component: IssueDetails,
      meta: { auth: true },
      props: true,
    },
  ],
});
