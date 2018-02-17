import { mapGetters } from 'vuex';

const navigationMixins = {
  computed: {
    isMenuOpened() {
      return this.$store.state.ui.menuOpen;
    },
    isAuthenticated() {
      return this.$store.getters.isAuthenticated;
    },
    authToken() {
      return this.$store.getters.authToken;
    },
  },
  methods: {
    goBack() {
      this.$router.go(-1);
    },
    toggleMenu() {
      this.$store.dispatch('toggleMenu');
    },
    logout() {
      console.log("will log out");
      return this.$store.dispatch('logout').then(() => {
        this.$store.commit('setMenuOpened', false);
        this.$router.push('/');
      }).catch(() => {
        console.log('wow, error?');
      });
    },
  },
};

export {
  navigationMixins,
};
