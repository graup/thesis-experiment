<template>
  <div class="viewport feed has-header" v-touch:swipe.right="showMenu" v-touch:swipe.left="hideMenu">
    <header>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
      <div class="view-title">Recent Ideas</div>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
    </header>
    <main class="content">
      <vue-pull-refresh :on-refresh="onRefresh" :config="{startLabel: 'Pull to reload', readyLabel: 'Release to reload', loadingLabel: 'Loading...', pullDownHeight: 60}">

        <div class="tutorial-message">
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
        </transition>

        <IssueList v-bind:items="issues" />

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
import Spinner from '@/components/elements/Spinner';
import VuePullRefresh from 'vue-pull-refresh';
import IssueList from "@/components/elements/IssueList";
import {navigationMixins} from "@/mixins";

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
  methods: {
    fetchData () {
      this.error = null;
      this.loading = true;
      
      return this.$store.dispatch('getIssues').then((issues) => {
        this.issues = issues;
        this.loading = false;
        this.error = null;
      });
    },
    onRefresh() {
      return this.$store.dispatch('fetchIssues').then((issues) => {
        this.issues = issues;
      });
    },
  },
  components: {
    MenuIcon,
    IssueList,
    VuePullRefresh,
    Spinner,
  },
};
</script>

<style scoped>

</style>
