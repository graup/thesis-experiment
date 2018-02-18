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
</style>
