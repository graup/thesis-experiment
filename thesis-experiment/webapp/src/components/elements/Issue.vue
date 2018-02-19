<template>
  <div class="issue" v-bind:class="{expanded}">
    <h2 class="issue-title" v-on:click="gotoDetails">{{item.title}}</h2>
    <div class="issue-detail" v-if="expanded">
      <p class="issue-text">{{item.text}}</p>
    </div>
    <div class="issue-stats">
      <span class="icon-with-text">
        <HeartIcon /> 123
      </span>
      <span class="icon-with-text">
        <CommentIcon /> 12
      </span>
      <span class="icon-with-text">
        <PersonIcon /> {{item.author.username}}
      </span>
    </div>
  </div>
</template>

<script>
import HeartIcon from 'icons/heart-outline';
import CommentIcon from 'icons/comment';
import PersonIcon from 'icons/account-circle';

export default {
  props: ['item', 'expanded'],
  methods: {
    gotoDetails() {
      let slug = this.$props.item.slug;
      this.$router.push({ name: 'issue-detail', params: { slug: slug, item: this.$props.item }});
    },
  },
  components: {
    HeartIcon,
    CommentIcon,
    PersonIcon,
  },
};
</script>

<style lang="scss">
.issue {
  box-sizing: border-box;
  margin: .75rem;   
  background-color: #ffffff;
  border-radius: 2px;
  box-shadow: 0 2px 5px rgba(50,50,93,.15);
  cursor: pointer;
}
.issue-title {
  font-size: 1em;
  font-weight: bold;
  margin: 0;
}
.issue-title, .issue-text, .issue-stats {
  padding: .75rem;
}
.issue-text {
  border-top: 1px solid #eee;
  font-size: 90%;
  margin: 0;
}
.issue-stats {
  border-top: 1px solid #eee;
  display: flex;

  :last-child {
    margin-left: auto;
  }
}

.icon-with-text {
  font-weight: bold;
  margin-right: 1rem;
  font-size: 90%;

  &:last-child {
    margin-right: 0;
  }

  .material-design-icon {
    svg {
      width: 16px;
      height: 16px;
      vertical-align: text-top;
      transform: translateY(1px);
    }
  }
}
</style>
