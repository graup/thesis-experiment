<template>
  <ul class="comment-list">
    <li v-for="item in items" v-bind:key="item.id">
      <Comment v-bind:item="item"></Comment>
    </li>
  </ul>
</template>

<script>
import Comment from "@/components/elements/Comment";

export default {
  props: ['items'],
  components: {
    Comment,
  },
};
</script>

<style lang="scss">
.comment-list {
  margin: 2rem 0;
  padding: 0;
  list-style: none;
}
</style>
