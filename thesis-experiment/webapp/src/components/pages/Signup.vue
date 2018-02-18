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
          </div>
          <div class="form-group">
            <input id="email" class="form-input" type="text" v-model="email" required />
            <label class="form-label" for="email">Email</label>
          </div>
          <div class="form-group">
            <input id="password" class="form-input" type="password" v-model="password" required />
            <label class="form-label" for="password">Password</label>
          </div>
          <div class="form-group">
            <input id="password2" class="form-input" type="password" v-model="password2" required />
            <label class="form-label" for="password2">Repeat password</label>
          </div>
          <div class="form-group button-group vertical spaced" style="max-width: 200px;">
            <my-button text="Sign up" primary={true} v-on:click.native.capture="signup" />
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
    };
  },
  methods: {
    aignup() {
      console.log('data', this.$data);
    },
  },
  components: {
    ChevronLeftIcon,
  },
};
</script>

<style scoped>
</style>
