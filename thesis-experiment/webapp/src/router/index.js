import Vue from 'vue';
import Router from 'vue-router';
import Start from '@/components/pages/Start';
import Login from '@/components/pages/Login';
import Signup from '@/components/pages/Signup';
import Feed from '@/components/pages/Feed';

Vue.use(Router);

export default new Router({
  routes: [
    { path: '/', component: Start },
    { path: '/login', component: Login, meta: { unauth: true } },
    { path: '/signup', component: Signup, meta: { unauth: true } },
    { path: '/feed', component: Feed, meta: { auth: true } },
  ],
});
