<template>
  <div class="button" v-bind:class="{primary: primary}" v-on:click="click">
    {{text}}
  </div>
</template>

<script>
export default {
  name: 'Button',
  props: ['text', 'primary', 'linkTo'],
  methods: {
    click() {
      if (typeof this.$props.linkTo !== 'undefined') {
        this.$router.push(this.$props.linkTo);
        return;
      }
    },
  },
};
</script>

<style lang="scss">
.button {
  display: inline-block;
  border-radius: 4px;
  font-size: 90%;
  line-height: 2.5;
  padding: 0 1.5em;
  font-weight: 600;

  background-color: #8FB5CE;
  color: #fff;
  cursor: pointer;
  box-sizing: border-box;

  &:hover {
    text-decoration: none;
    background-color: darken(#8FB5CE, 10%);
  }

  &.primary {
    background-color: #386b8d;

    &:hover {
      background-color: darken(#386b8d, 10%);
    }
  }

  &.huge {
    font-size: 110%;
  }
}
.button-group {
  display: flex;

  &.horizontal {

  }
  &.vertical {
    flex-direction: column;
    align-items: center;
    margin-left: auto;
    margin-right: auto;

    .button {
      margin-bottom: 1rem;
      display: block;
      width: 100%;

      &:last-child {
        margin-bottom: 0;
      }
    }

  }
}
</style>
