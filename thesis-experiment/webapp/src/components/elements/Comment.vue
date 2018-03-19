<template>
  <div class="comment">
    <div class="content">
      {{item.text}}

      <span class="date">{{item.created_date | moment("from", "now")}}</span>
    </div>
    <div class="author">{{item.author.username}}</div>
  </div>
</template>

<script>
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  props: ['item', ],
  methods: {
  },
  components: {
  },
};
</script>

<style lang="scss">
.comment {
  margin: 1rem 0;

  .author {
    font-size: .8em;
    color: #888;
    margin: 0 0 0 1.25rem;
    text-transform: uppercase;
    font-weight: 500;
  }
  .content {
    font-size: .9em;
    line-height: 1.5;
    background-color: #fff;
    border-radius: 10px;
    padding: .75rem;
    margin: .5rem;
    margin-bottom: 12px;

    position: relative;

    &:before {
      content: "";
      position: absolute;
      left: 16px;
      bottom: 0;
      border: 8px solid transparent;
      border-top-color: #fff;
      transform: translateY(16px);
    }
  }

  .date {
    display: block;
    font-size: .9em;
    text-align: right;
    color: #666;
  }
}
</style>
