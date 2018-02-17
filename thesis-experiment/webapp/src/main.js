import Vue from 'vue';
import Vuex from 'vuex';

import Logo from '@/components/elements/Logo';
import Button from '@/components/elements/Button';

import App from './App';
import router from './router';
import store from './store';

Vue.config.productionTip = false;

Vue.component('app-logo', Logo);
Vue.component('my-button', Button);

router.beforeEach((to, from, next) => {
  console.log('route', from, to);
  const authRequired = to.matched.some((route) => route.meta.auth);
  const unauthRequired = to.matched.some((route) => route.meta.unauth);
  const authed = store.state.user.isAuthenticated;
  console.log(authRequired, unauthRequired, authed);
  if (authRequired && !authed) {
    next('/login');
  } else if (unauthRequired && authed) {
    next('/feed');
  } else {
    next();
  }
});

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  render: h => h(App),
});
