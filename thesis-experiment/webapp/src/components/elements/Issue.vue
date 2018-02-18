<template>
  <li class="issue" v-on:click="gotoDetails">
    {{item.text}}
  </li>
</template>

<script>
export default {
  props: ['item'],
  methods: {
    gotoDetails() {
      let slug = this.$props.item.slug;
      this.$router.push({ name: 'issue-detail', params: { slug: slug, item: this.$props.item }});
    },
  },
};
</script>

<style lang="scss">
.issue {
  padding: 1rem;
  box-sizing: border-box;
  margin: .75rem;   
  background-color: #ffffff;
  border-radius: 2px;
  box-shadow: 0 2px 5px rgba(50,50,93,.15);
  cursor: pointer;
}
</style>
