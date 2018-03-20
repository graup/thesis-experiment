import Vue from 'vue';
import Vue2TouchEvents from 'vue2-touch-events';
import VueLocalStorage from 'vue-localstorage';
import VueMoment from 'vue-moment';
import VueI18n from 'vue-i18n';

import Logo from '@/components/elements/Logo';
import Button from '@/components/elements/Button';

import App from './App';
import router from './router';
import store from './store';

Vue.config.productionTip = false;

Vue.use(Vue2TouchEvents);
Vue.use(VueLocalStorage, { bind: true });
Vue.use(VueMoment);
Vue.use(VueI18n);

Vue.component('app-logo', Logo);
Vue.component('my-button', Button);

router.beforeEach((to, from, next) => {
  console.log('Route transition', from.path, '->', to.path);
  const authRequired = to.matched.some(route => route.meta.auth);
  const unauthRequired = to.matched.some(route => route.meta.unauth);
  const authed = store.state.user.isAuthenticated;
  if (authRequired && !authed) {
    next('/login');
  } else if (unauthRequired && authed) {
    next('/feed');
  } else {
    next();
  }
});

const i18n = new VueI18n({
  locale: 'en',
  fallbackLocale: 'en',
});

/* eslint-disable no-new */
new Vue({
  el: '#app',
  router,
  store,
  i18n,
  render: h => h(App),
  localStorage: {
    completedTutorials: {
      type: Object,
      default: {},
    },
  },
});
