<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">Idea Details</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>
    <main class="content">

      <div class="tutorial-message">
        Here you can see details about the idea and comments that other people left.
        If you agree with this issue, how about showing your support by tapping the heart?
        If you have another opinion, try writing a short comment.
      </div>

      <div class="loading" v-if="loading">
        Loading...
      </div>

      <div v-if="issue">
        <Issue v-bind:item="issue" expanded="true" />
      </div>

      <div class="empty-state">
        No comments yet. <br>
        You can be the first!
      </div>

    </main>
    <footer>
      <div class="call-to-action">
        <my-button text="Leave a comment" primary={true} link-to="" />
      </div>
    </footer>
  </div>
</template>

<script>
import ChevronLeftIcon from "icons/chevron-left";
import {navigationMixins} from "@/mixins";
import Issue from "@/components/elements/Issue";

export default {
  mixins: [navigationMixins],
  props: ['slug', 'item'],
  data () {
    return {
      loading: false,
      issue: null,
      error: null
    }
  },
  created () {
    this.fetchData();
  },
  watch: {
    '$route': 'fetchData'
  },
  components: {
    ChevronLeftIcon,
    Issue,
  },
  methods: {
    fetchData () {
      if (this.$props.item) {
        // issue was passed in through router, no need to load again
        this.issue = this.$props.item;
        return;
      }
      this.error = this.issue = null;
      this.loading = true;
      
      this.$store.dispatch('getIssue', {slug: this.$props.slug}).then((issue) => {
        this.issue = issue;
        this.loading = false;
      });
    },
  },
};
</script>

<style scoped>

</style>
