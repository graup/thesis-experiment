<template>
  <div class="call-to-action">
    <p>{{leadText}}</p>
    <my-button :text="$t('cta-button-text')" primary={true} :link-to="{name: 'new-issue'}" />
    <div v-if="treatment">
      <p class="message" v-html="$t('cta-sub-text-treatment')"></p>
    </div>
  </div>
</template>

<i18n>
{
  "en": {
    "cta-lead-text": "Make our community a better place!",
    "cta-lead-text-treatment": "We need your contribution!",
    "cta-sub-text-treatment": "24 other people contributed today.<br>Your ideas matter.",
    "cta-button-text": "Share your idea"
  },
  "ko": {
    "cta-lead-text": "우리 지역 사회를 더 좋은 곳으로 만드십시오!",
    "cta-lead-text-treatment": "당신의 기여가 필요합니다!",
    "cta-sub-text-treatment": "오늘 24 명의 사람들이 참여했습니다.<br>당신의 아이디어는 소중합니다.",
    "cta-button-text": "당신의 아이디어 공유하기"
  }
}
</i18n>

<script>

export default {
  props: ['treatment'],
  computed: {
    leadText() {
      return this.$props.treatment ? this.$t('cta-lead-text-treatment') : this.$t('cta-lead-text');
    }
  }
};
</script>

<style lang="scss" scoped>
p {
  margin-bottom: .75em;
}
.message {
  margin: .75em 0 0;
}
.call-to-action {
  font-size: .9em;
}
</style>
