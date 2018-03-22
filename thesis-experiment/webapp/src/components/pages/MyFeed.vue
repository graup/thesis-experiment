<template>
  <div class="viewport feed has-header" v-touch:swipe.right="showMenu" v-touch:swipe.left="hideMenu">
    <header>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
      <div class="view-title">My Ideas</div>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
    </header>
    <main class="content">
      <vue-pull-refresh :on-refresh="onRefresh" :config="{startLabel: 'Pull to reload', readyLabel: 'Release to reload', loadingLabel: 'Loading...', pullDownHeight: 60}">

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

        <div class="empty-state" v-if="!loading && !issues.length">
          Nothing yet. <br>
          Post your first idea now!
        </div>

      </vue-pull-refresh>
    </main>
    <footer>
      <FeedCallToAction treatment="user.active_treatment.name=='orientation_autonomy'" />
    </footer>
  </div>
</template>

<script>
import MenuIcon from "icons/menu";
import ErrorIcon from "icons/cloud-off-outline";
import Spinner from '@/components/elements/Spinner';
import VuePullRefresh from 'vue-pull-refresh';
import IssueList from "@/components/elements/IssueList";
import FeedCallToAction from "@/components/elements/FeedCallToAction";
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
        this.issues = issues.filter(item => item.author.username == this.user.username);
        this.loading = false;
        this.error = null;
      }).catch(error => {
        this.error = true;
        this.loading = false;
        console.error(error);
      })
    },
    onRefresh() {
      this.error = null;
      return this.$store.dispatch('fetchIssues').then((issues) => {
        this.issues = issues.filter(item => item.author.username == this.user.username);
      });
    },
  },
  components: {
    MenuIcon,
    ErrorIcon,
    IssueList,
    VuePullRefresh,
    Spinner,
    FeedCallToAction,
  },
};
</script>

<style scoped>

</style>
