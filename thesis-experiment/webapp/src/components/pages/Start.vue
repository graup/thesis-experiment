<template>
  <div class="viewport hello">
    <header></header>
    <main class="content">
      <app-logo instance-name="KAIST" />

      <p class="intro">
        {{ $t('hello') }}
      </p>

      <div class="button-group vertical spaced" style="max-width: 200px;">
        <my-button :text="$t('signup')" link-to="signup" primary={true} />
        <my-button :text="$t('login')" link-to="login" />
      </div>

      <div v-if="!touchDevice" class="message warning">
        This application is designed for use on mobile devices.<br>
        Please visit this web site on a mobile device.
      </div>
    </main>
    <footer></footer>
  </div>
</template>

<i18n>
{
  "en": {
    "hello": "Join us in collecting important issues and ideas for the future of KAIST. We need everyone’s contribution!",
    "signup": "Sign up",
    "login": "Log in"
  },
  "ko": {
    "hello": "KAIST의 미래를위한 중요한 이슈와 아이디어를 수집하십시오. 모든 사람의 공헌이 필요합니다!",
    "signup": "회원 가입",
    "login": "로그인"
  }
}
</i18n>

<script>
import {localeMixin} from "@/mixins";

export default {
  mixins: [localeMixin],
  name: 'Start',
  data() {
    return {
      touchDevice: !!('ontouchstart' in window),
    };
  },
};
</script>

<style scoped>
.content {
  text-align: center;
}
.intro {
  padding: 0 2em;
  margin-bottom: 3rem;
  font-size: 1.1em;
}
.message {
  margin: 3rem 1rem 0;
  border: 1px solid orange;
  padding: 1rem;
  background-color: #fff;
  border-radius: 5px;
}
</style>
