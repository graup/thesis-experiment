<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="gotoRoute('/feed')"><ChevronLeftIcon /></div>
      <div class="view-title">Idea Details</div>
      <div class="icon-button" v-on:click="gotoRoute('/feed')"><ChevronLeftIcon /></div>
    </header>
    <main class="content">

      <vue-pull-refresh :on-refresh="onRefresh" :config="{startLabel: 'Pull to reload', readyLabel: 'Release to reload', loadingLabel: 'Loading...', pullDownHeight: 60}">

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

      </vue-pull-refresh>

    </main>
    <footer>
      <div class="call-to-action">
        <div v-if="!commentMode">
          <p v-if="user.active_treatment && user.active_treatment.name=='orientation_autonomy'">
            Let's share our diverse viewpoints! 
          </p>
          <my-button text="Leave a comment" primary={true} v-on:click.native="toggleCommentMode()" />
        </div>
        <div v-if="commentMode" class="comment-form">
          <textarea name="text" class="comment-text" ref="commentText" autofocus placeholder="Write a comment..." v-model="commentText"></textarea>
          <my-button v-on:click.native="submitComment()" primary={true} icon={true} :loading="sendingComment"><SendIcon /></my-button>
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
import VuePullRefresh from 'vue-pull-refresh';


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
      commentText: '',
      sendingComment: false,
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
    VuePullRefresh,
  },
  methods: {
    onRefresh() {
      this.error = null;
      let slug = this.issue.slug || this.$props.slug;
      return Promise.all([
        this.$store.dispatch('fetchIssue', { slug }).then((issue) => {
          this.issue = issue;
        }),
        this.$store.dispatch('fetchComments', { slug }).then((comments) => {
          this.comments = comments;
        }),
      ]).catch((error) => {
        this.error = error;
      });
    },
    fetchData () {
      if (this.$props.item) {
        // issue was passed in through router, no need to load again
        this.issue = this.$props.item;
      } else {
        this.error = this.issue = null;
        this.loading = true;
        this.$store.dispatch('getIssue', {slug: this.$props.slug}).then((issue) => {
          this.issue = issue;
          this.loading = false;
        });
      }

      this.$store.dispatch('getComments', {slug: this.$props.slug}).then((comments) => {
        this.comments = comments;
        this.loading = false;
      });
    },
    submitComment() {
      this.sendingComment = true;
      let comment = { text: this.commentText, issue: this.issue.id };
      let started = (new Date()).getTime();
      this.$store.dispatch('createComment', {slug: this.issue.slug, comment}).then((comment) => {
        let wait = Math.max(1, 1000 - ((new Date()).getTime() - started)); // wait at least 1 s
        setTimeout(() => {
          this.commentText = '';
          this.sendingComment = false;
          this.commentMode = false;
          this.comments.unshift(comment);
          this.issue.comment_count += 1;
        }, wait);
      });
    },
    toggleCommentMode() {
      this.commentMode = !this.commentMode;
      if (this.commentMode) {
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
    
    padding: 10px;
    margin-right: 1em;
    border: none;
    background-color: #fff;
  }
  .button {

  }
}
</style>
