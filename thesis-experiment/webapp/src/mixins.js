const navigationMixins = {
  computed: {
    isMenuOpened() {
      return this.$store.state.ui.menuOpen;
    },
    isAuthenticated() {
      return this.$store.state.user.isAuthenticated;
    },
    authToken() {
      return this.$store.getters.authToken;
    },
    user() {
      return this.$store.state.user.user;
    },
  },
  methods: {
    goBack() {
      this.$router.go(-1);
    },
    gotoRoute(route) {
      this.$router.push(route);
    },
    toggleMenu() {
      this.$store.dispatch('toggleMenu');
    },
    showMenu() {
      this.$store.commit('setMenuOpened', true);
    },
    hideMenu() {
      this.$store.commit('setMenuOpened', false);
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
