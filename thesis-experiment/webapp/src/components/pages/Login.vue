<template>
  <div class="viewport hello has-header">
    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">Log in</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>

    <main class="content">

      <div class="form-wrapper">
        
        <form action="" class="form">
          <div class="form-group">
            <input id="username" class="form-input" type="text" v-model="username" required />
            <label class="form-label" for="username">Username or email</label>
          </div>
          <div class="form-group">
            <input id="password" class="form-input" type="password" v-model="password" required />
            <label class="form-label" for="password">Password</label>
          </div>
          <div class="form-group button-group vertical spaced" style="max-width: 200px;">
            <my-button text="Log in" primary={true} v-on:click.native.capture="login" />
          </div>
        </form>
      </div>
      
    </main>
    <footer></footer>
  </div>
</template>

<script>
import ChevronLeftIcon from "icons/chevron-left";
import { mapGetters } from 'vuex'
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  data() {
    return {
      username: '',
      password: ''
    };
  },
  computed: {
    ...mapGetters([
      'isAuthenticated',
    ])
  },
  methods: {
    login() {
      const data = new FormData();
      data.set('username', this.$data.username);
      data.set('password', this.$data.password);
      data.set('grant_type', 'password');
      data.set('client_id', 'webapp');
      const requestOptions = {config: { headers: {'Content-Type': 'multipart/form-data' }}};
      this.$store.dispatch('login', { user: data, requestOptions }).then(() => {
        this.$router.push('feed');
      });
    },
  },
  components: {
    ChevronLeftIcon,
  },
};
</script>

<style scoped>
</style>

