<template>
  <div class="viewport hello has-header">
    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">Sign up</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>

    <main class="content">

      <div class="form-wrapper">

        <form action="" class="form">
          <div class="form-group">
            <input id="username" class="form-input" type="text" v-model="username" required />
            <label class="form-label" for="username">Username</label>
            <div class="error" v-if="errors.username">{{errors.username.join(' ')}}</div>
          </div>
          <div class="form-group">
            <input id="email" class="form-input" type="text" v-model="email" required />
            <label class="form-label" for="email">Email</label>
            <div class="error" v-if="errors.email">{{errors.email.join(' ')}}</div>
          </div>
          <div class="form-group">
            <input id="password" class="form-input" type="password" v-model="password" required />
            <label class="form-label" for="password">Password</label>
            <div class="error" v-if="errors.password">{{errors.password.join(' ')}}</div>
          </div>
          <div class="form-group">
            <input id="password2" class="form-input" type="password" v-model="password2" required />
            <label class="form-label" for="password2">Repeat password</label>
            <div class="error" v-if="errors.password2">{{errors.password2.join(' ')}}</div>
          </div>
          <div class="form-group button-group vertical spaced" style="max-width: 200px;">
            <my-button text="Sign up" primary={true} v-on:click.native.capture="signup" v-bind:loading="loading" />
          </div>
        </form>
      </div>
    </main>
    <footer></footer>
  </div>
</template>

<script>
import ChevronLeftIcon from "icons/chevron-left";
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  name: 'Start',
  data() {
    return {
      username: '',
      email: '',
      password: '',
      password2: '',
      errors: {},
      loading: false,
    };
  },
  methods: {
    signup() {
      if (this.$data.password !== this.$data.password2) {
        this.$data.errors = {password2: ['Passwords do not match.']};
        return;
      }
      this.$data.loading = true;

      const data = new FormData();
      data.set('username', this.$data.username);
      data.set('password', this.$data.password);
      data.set('email', this.$data.email);
      this.$store.dispatch('signup', { user: data, requestOptions: {} }).then(() => {
        this.$router.push('feed');
      }).catch(error => {
        this.$data.errors = error.response.data;
        this.$data.loading = false;
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
