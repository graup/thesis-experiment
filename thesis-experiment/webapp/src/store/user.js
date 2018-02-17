import Vue from 'vue';
import VueAuthenticate from 'vue-authenticate';
import VueAxios from 'vue-axios';
import axios from 'axios';

Vue.use(VueAxios, axios);

const vueAuth = VueAuthenticate.factory(Vue.prototype.$http, {
  baseUrl: 'http://localhost:8000',
  registerUrl: 'auth/signup',
});

export default {
  state: {
    isAuthenticated: vueAuth.isAuthenticated(),
  },
  getters: {
    isAuthenticated() {
      let c = vueAuth.isAuthenticated();
      console.log('getter', c);
      return c;
    },
    authToken() {
      return vueAuth.getToken();
    }
  },
  mutations: {
    isAuthenticated(state, payload) {
      state.isAuthenticated = payload.isAuthenticated;
    },
  },
  actions: {
    login({ commit, state }, payload) {
      return vueAuth.login(payload.user, payload.requestOptions).then((response) => {
        commit('isAuthenticated', {
          isAuthenticated: vueAuth.isAuthenticated(),
        });
        console.log('ok now?', vueAuth.isAuthenticated(), state.isAuthenticated);
      });
    },
    logout({ commit, state }, payload) {
      return vueAuth.logout().then(() => {
        commit('isAuthenticated', {
          isAuthenticated: false,
        });
      });
    },
  },
};