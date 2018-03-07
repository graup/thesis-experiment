<template>
  <div class="viewport feed has-header" v-touch:swipe.right="showMenu" v-touch:swipe.left="hideMenu">
    <header>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
      <div class="view-title">Recent Ideas</div>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
    </header>
    <main class="content">
      <vue-pull-refresh :on-refresh="onRefresh" :config="{startLabel: 'Pull to reload', readyLabel: 'Release to reload', loadingLabel: 'Loading...', pullDownHeight: 60}">

        <div class="tutorial-message" v-if="tutorial_feed">
          <strong>Welcome to Many Ideas for KAIST!</strong><br>
          We're happy to have you here.
          On this page, you can see posts by other members.
          Do you see anything you are interested in?<br>
          Try tapping on a post.
        </div>

        <transition name="fade-up">
          <div class="loading" v-if="loading">
            <Spinner />
            Loading...
          </div>
          <div class="loading loading-error" v-if="error">
            <ErrorIcon /><br>
            An error occured while loading.<br>
            Try to reload this page.
          </div>
        </transition>

        <IssueList v-bind:items="issues" v-on::click.native="completeTutorial('feed')" />

      </vue-pull-refresh>
    </main>
    <footer>
      <div class="call-to-action">
        <p>We need your contribution!</p>
        <my-button text="Submit new idea" primary={true} :link-to="{name: 'new-issue'}" />
      </div>
    </footer>
  </div>
</template>

<script>
import MenuIcon from "icons/menu";
import ErrorIcon from "icons/cloud-off-outline";
import Spinner from '@/components/elements/Spinner';
import VuePullRefresh from 'vue-pull-refresh';
import IssueList from "@/components/elements/IssueList";
import {navigationMixins} from "@/mixins";
import {hasCompletedTutorial, completeTutorial} from "@/utils/tutorials";

export default {
  mixins: [navigationMixins],
  data () {
    return {
      loading: false,
      issues: null,
      error: null
    }
  },
  created () {
    this.fetchData();
  },
  watch: {
    '$route': 'fetchData'
  },
  computed: {
    tutorial_feed() {
      return ! hasCompletedTutorial(this.$localStorage, 'feed');
    },
  },
  methods: {
    completeTutorial(name) {
      completeTutorial(this.$localStorage, name);
    },
    fetchData () {
      this.error = null;
      this.loading = true;
      
      return this.$store.dispatch('getIssues').then((issues) => {
        this.issues = issues;
        this.loading = false;
        this.error = null;
      }).catch(error => {
        this.error = true;
        this.loading = false;
      })
    },
    onRefresh() {
      this.error = null;
      return this.$store.dispatch('fetchIssues').then((issues) => {
        this.issues = issues;
      });
    },
  },
  components: {
    MenuIcon,
    ErrorIcon,
    IssueList,
    VuePullRefresh,
    Spinner,
  },
};
</script>

<style scoped>

</style>
