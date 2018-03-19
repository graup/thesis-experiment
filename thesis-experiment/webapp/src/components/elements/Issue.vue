<template>
  <div class="issue" v-bind:class="{expanded}">
    <h2 class="issue-title" v-on:click="gotoDetails">{{item.title}}</h2>
    <div class="issue-detail" v-if="expanded">
      <p class="issue-text">{{item.text}}</p>
    </div>
    <div class="issue-stats">
      <span class="icon-with-text" v-on:click.capture.stop="toggleLike">
        <span class="like-container" v-bind:class="{liked: item.user_liked}">
          <HeartIcon /> 
          <HeartFilledIcon fillColor="red" /> 
        </span> {{item.like_count}}
      </span>
      <span class="icon-with-text">
        <CommentIcon /> {{item.comment_count}}
      </span>
      <span class="icon-with-text">
        <span class="date">{{item.created_date | moment("from", "now")}}</span>
        <span v-bind:class="{isAuthor}"><PersonIcon /> {{item.author.username}}</span>
        
      </span>
      
    </div>
  </div>
</template>

<script>
import HeartIcon from 'icons/heart-outline';
import HeartFilledIcon from 'icons/heart';
import CommentIcon from 'icons/comment-outline';
import PersonIcon from 'icons/account-circle';
import {completeTutorial} from "@/utils/tutorials";
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  props: ['item', 'expanded'],
  data () {
    return {
      liked: false,
    }
  },
  computed: {
    isAuthor() {
      return this.user.username == this.$props.item.author.username;
    }
  },
  methods: {
    gotoDetails() {
      completeTutorial(this.$localStorage, 'feed');
      let slug = this.$props.item.slug;
      this.$router.push({ name: 'issue-detail', params: { slug: slug, item: this.$props.item }});
    },
    toggleLike() {
      console.log("like");
      if (this.$props.item.user_liked) {
        this.$props.item.like_count -= 1;
      } else {
        this.$props.item.like_count += 1;
      }
      this.$props.item.user_liked = !this.$props.item.user_liked;
      this.$store.dispatch('likeIssue', { issue: this.$props.item });
    },
  },
  components: {
    HeartIcon,
    HeartFilledIcon,
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
}
.issue-title {
  font-size: 1em;
  font-weight: normal;
  margin: 0;
  line-height: 1.3;
  cursor: pointer;
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
  font-size: 85%;
  cursor: pointer;

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

  .isAuthor svg {
    fill: #039e63;
  }
  .isAuthor {
    color: #039e63;
  }
  .date {
    color: #777;
    font-weight: 300;
  }
}

.like-container {
  position: relative;
  width: 16px;
  display: inline-block;
  vertical-align: top;

  .material-design-icon {
    position: absolute;
    left: 0;
    transition: all .3s cubic-bezier(0.14, 0.83, 0.37, 1.35);
  }
  .heart-icon {
    transform: scale(0) translateY(0px);
    transform-origin: center center;
  }

  &.liked {
    .heart-outline-icon {
      opacity: 0;
    }
    .heart-icon {
      transform: scale(1.2) translateY(-1px);
    }
  }
}
</style>
