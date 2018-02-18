<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">Idea Details</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>
    <main class="content">

      <div class="loading" v-if="loading">
        Loading...
      </div>

      <div v-if="issue">

        <p>Idea {{slug}}</p>
        <p>{{issue.text}}</p>

      </div>

    </main>
    <footer></footer>
  </div>
</template>

<script>
import ChevronLeftIcon from "icons/chevron-left";
import {navigationMixins} from "@/mixins";

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
  },
  methods: {
    fetchData () {
      if (this.$props.item) {
        this.issue = this.$props.item;
        return;
      }
      this.error = this.issue = null;
      this.loading = true;
      
      
      this.$store.dispatch('getIssue', {slug: this.$props.slug}).then((issue) => {
        this.issue = issue;
        this.loading = false;
      });
      //{id: 1, text: 'newly fetched'}
      /*getPost(this.$route.params.id, (err, post) => {
        this.loading = false
        if (err) {
          this.error = err.toString()
        } else {
          this.issue = post
        }
      })
      */
    },
  },
};
</script>

<style scoped>

</style>
