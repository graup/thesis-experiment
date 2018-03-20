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

        <div class="tutorial-message" v-if="issue.author.username==user.username && !comments.length && issue.like_count<=1">
          This is your idea! Good job. Let's wait until other members give their opinion.
        </div>
        
        <Issue v-bind:item="issue" expanded="true" />
      
        <div class="empty-state" v-if="!comments.length">
          No comments yet. <br>
          You can be the first!
        </div>

        <CommentList v-bind:items="comments" />

      </div>

    </main>
    <footer>
      <div class="call-to-action">
        <div v-if="!commentMode">
          <my-button text="Leave a comment" primary={true} v-on:click.native="toggleCommentMode()" />
        </div>
        <div v-if="commentMode" class="comment-form">
          <textarea name="text" class="comment-text" ref="commentText" autofocus placeholder="Write a comment..."></textarea>
          <my-button v-on:click.native="submitComment()" primary={true} icon={true}><SendIcon /></my-button>
        </div>
      </div>
    </footer>
  </div>
</template>

<script>
import Spinner from '@/components/elements/Spinner';
import ChevronLeftIcon from "icons/chevron-left";
import SendIcon from "icons/send";
import {navigationMixins} from "@/mixins";
import Issue from "@/components/elements/Issue";
import CommentList from "@/components/elements/CommentList";
import autosize from 'autosize';

export default {
  mixins: [navigationMixins],
  props: ['slug', 'item'],
  data () {
    return {
      loading: false,
      issue: null,
      comments: [],
      error: null,
      commentMode: false,
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
    CommentList,
    SendIcon,
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

      this.$store.dispatch('getComments', {slug: this.$props.slug}).then((comments) => {
        this.comments = comments;
        this.loading = false;
      });
    },
    submitComment() {
      this.$data.commentMode = false;
    },
    toggleCommentMode() {
      this.$data.commentMode = !this.$data.commentMode;
      if (this.$data.commentMode) {
        this.$nextTick(() => {
          autosize(this.$refs.commentText);
          this.$refs.commentText.focus()
        });
      }
    },
  },
};
</script>

<style lang="scss" scoped>
.comment-form {
  display: flex;
  align-items: center;

  .comment-text {
    flex: 1;
    
    padding: 5px;
    margin-right: 1em;
    border: none;
    background-color: #fff;
  }
  .button {

  }
}
</style>
