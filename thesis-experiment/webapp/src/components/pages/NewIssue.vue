<template>
  <div class="viewport post-issue has-header">
    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">New Idea</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>
    <main class="content">
      <p class="intro">
        Everybody has great ideas that our community can benefit from.
        Tell us what you think!
      </p>

      <div class="form-wrapper form-wide">
        <form action="" class="form">
          <div class="form-group">
            <input id="title" class="form-input" type="text" v-model="title" required />
            <label class="form-label" for="title">Title</label>
            <div class="error" v-if="errors.title">{{errors.title.join(' ')}}</div>
          </div>
          <div class="form-group">
            <textarea id="text" class="form-input" v-model="text" required></textarea>
            <label class="form-label" for="text">Description</label>
            <div class="error" v-if="errors.text">{{errors.text.join(' ')}}</div>
          </div>
          <div class="form-group button-group vertical spaced" style="max-width: 200px;">
            <my-button text="Continue" primary={true} v-on:click.native.capture="createIssue" />
          </div>
        </form>
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
  components: {
    ChevronLeftIcon,
  },
  data() {
    return {
      title: '',
      text: '',
      categories: [1],
      errors: {},
      loading: false,
    };
  },
  methods: {
    createIssue() {
      this.$data.loading = true;
      const data = { title: this.$data.title, text: this.$data.text, categories: this.$data.categories };
      this.$store.dispatch('createIssue', { issue: data }).then((issue) => {
        this.$router.push({ name: 'issue-detail', params: { slug: issue.slug, item: issue }});
      }).catch(error => {
        this.$data.errors = error.response.data;
        this.$data.loading = false;
      });
    },
  },
};
</script>

<style scoped>
.intro {
  padding: 0 2em;
  margin: 1rem 0;
  text-align: center;
}
textarea {
  height: 150px;
}
</style>
