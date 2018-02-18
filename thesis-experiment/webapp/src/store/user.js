import Vue from 'vue';
import VueAuthenticate from 'vue-authenticate';
import VueAxios from 'vue-axios';
import axios from 'axios';
import $http from '../utils/http';
import { apiGet } from '../utils/api';

Vue.use(VueAxios, axios);

const vueAuth = VueAuthenticate.factory(Vue.prototype.$http, {
  baseUrl: process.env.API_BASE_URL,
  registerUrl: 'auth/signup',

  bindRequestInterceptor: () => {
    /* eslint-disable no-param-reassign, dot-notation */
    $http.interceptors.request.use((request) => {
      console.log(`HTTP ${request.method} ${request.url}`, this);
      if (vueAuth.isAuthenticated()) {
        request.headers['Authorization'] = [
          vueAuth.options.tokenType, vueAuth.getToken(),
        ].join(' ');
      } else {
        delete request.headers['Authorization'];
      }
      return request;
    });
  },

  bindResponseInterceptor: () => {
    $http.interceptors.response.use((response) => {
      vueAuth.setToken(response);
      return response;
    });
  },
});

export default {
  state: {
    isAuthenticated: vueAuth.isAuthenticated(),
    user: {},
    user_loaded: false,
  },
  getters: {
    isAuthenticated() {
      return vueAuth.isAuthenticated();
    },
    authToken() {
      return vueAuth.getToken();
    },
  },
  mutations: {
    isAuthenticated(state, payload) {
      state.isAuthenticated = payload.isAuthenticated;
      state.user_loaded = false;
    },
    setUser(state, user) {
      state.user = user;
      state.user_loaded = true;
    },
  },
  actions: {
    getCurrentUser({ commit, state }) {
      return new Promise((resolve, reject) => {
        if (state.user_loaded) {
          resolve(state.user);
        } else {
          apiGet('users/me/').then((response) => {
            const user = response.data;
            commit('setUser', user);
            resolve(user);
          }).catch(reject);
        }
      });
    },
    login({ commit }, payload) {
      return vueAuth.login(payload.user, payload.requestOptions).then(() => {
        commit('isAuthenticated', {
          isAuthenticated: vueAuth.isAuthenticated(),
        });
      });
    },
    logout({ commit }) {
      return vueAuth.logout().then(() => {
        commit('isAuthenticated', {
          isAuthenticated: false,
        });
      });
    },
  },
};