<template>
  <div class="viewport hello">
    <header></header>
    <main class="content">
      <app-logo instance-name="KAIST" />

      <p class="intro">
        Join us in collecting important issues and ideas for the future of KAIST.
        We need everyone’s contribution!
      </p>

      <div class="button-group vertical spaced" style="max-width: 200px;">
        <my-button text="Sign up" primary={true} link-to="signup" />
        <my-button text="Log in" link-to="login" />
      </div>

      <div v-if="!touchDevice" class="message warning">
        This application is designed for use on mobile devices.<br>
        Please visit this web site on a mobile device.
      </div>
    </main>
    <footer></footer>
  </div>
</template>

<script>

export default {
  name: 'Start',
  data() {
    return {
      msg: 'Welcome to Your Vue.js App. Does it work?',
      touchDevice: !!('ontouchstart' in window),
    };
  },
};
</script>

<style scoped>
.content {
  text-align: center;
}
.intro {
  padding: 0 2em;
  margin-bottom: 3rem;
}
.message {
  margin: 3rem 1rem 0;
  border: 1px solid orange;
  padding: 1rem;
  background-color: #fff;
  border-radius: 5px;
}
</style>
