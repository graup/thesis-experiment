<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="gotoRoute('/feed')"><ChevronLeftIcon /></div>
      <div class="view-title">Idea Details</div>
      <div class="icon-button" v-on:click="gotoRoute('/feed')"><ChevronLeftIcon /></div>
    </header>
    <main class="content">

      <transition name="fade-up">
        <div class="loading" v-if="loading">
          <Spinner />
          Loading...
        </div>
      </transition>

      <div v-if="issue">
        <div class="tutorial-message" v-if="issue.author.username!=user.username">
          Here you can see details about the idea and comments that other people left.
          If you agree with this issue, how about showing your support by tapping the heart?
          If you have another opinion, try writing a short comment.
        </div>

        <div class="tutorial-message" v-if="issue.author.username==user.username">
          This is your idea! Good job. Let's wait until other members give their opinion.
        </div>
        
        <Issue v-bind:item="issue" expanded="true" />
      
        <div class="empty-state">
          No comments yet. <br>
          You can be the first!
        </div>

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
import Spinner from '@/components/elements/Spinner';
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
    Spinner,
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
