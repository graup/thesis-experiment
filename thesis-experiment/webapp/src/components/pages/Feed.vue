<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
      <div class="view-title">Recent Ideas</div>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
    </header>
    <main class="content">

      <div class="tutorial-message">
        <strong>Welcome to Many Ideas for KAIST!</strong><br>
        We're happy to have you here.
        On this page, you can see posts by other members.
        Do you see anything you are interested in?<br>
        Try tapping on a post.
      </div>

      <IssueList v-bind:items="issues" />

    </main>
    <footer></footer>
  </div>
</template>

<script>
import MenuIcon from "icons/menu";
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
      
      this.$store.dispatch('getIssues').then((issues) => {
        this.issues = issues;
        this.loading = false;
      });
    },
  },
  components: {
    MenuIcon,
    IssueList,
  },
};
</script>

<style scoped>

</style>
