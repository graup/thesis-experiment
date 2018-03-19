


<template>
  <div class="call-to-action">
    <p>{{leadText}}</p>
    <my-button text="Share your idea" primary={true} :link-to="{name: 'new-issue'}" />
    <div v-if="treatment">
      <p class="message">
        24 other people contributed today.<br>
        Your ideas matter.
      </p>
    </div>
  </div>
</template>

<script>

export default {
  props: ['treatment'],
  computed: {
    leadText() {
      return this.$props.treatment ? 'Make our community a better place!' : 'We need your contribution!';
    }
  }
};
</script>

<style lang="scss" scoped>
p {
  margin-bottom: .75em;
}
.message {
  margin: .75em 0 0;
}
.call-to-action {
  font-size: .9em;
}
</style>
