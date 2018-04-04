<template>
  <div class="viewport has-header" v-touch:swipe.right="showMenu" v-touch:swipe.left="hideMenu">
    <header>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
      <div class="view-title">FAQ</div>
      <div class="icon-button" v-on:click="toggleMenu"><MenuIcon /></div>
    </header>
    <main class="content">
      <div style="text-align: center">
        <app-logo instance-name="KAIST" />
      </div>

      <p class="question" v-html="$t('faq-q-1')" />
      <p v-html="$t('faq-a-1')" />

      <p class="question" v-html="$t('faq-q-2')" />
      <p v-html="$t('faq-a-2')" v-if="treatmentName=='baseline'" />
      <p v-html="$t('faq-a-2-autonomy')" v-if="treatmentName=='autonomy'" />
      <p v-html="$t('faq-a-2-control')" v-if="treatmentName=='control'" />

      <p class="question" v-html="$t('faq-q-3')" />
      <p v-html="$t('faq-a-3')" />

      <p class="question" v-html="$t('faq-q-4')" />
      <p v-html="$t('faq-a-4')" />

      <p class="question" v-html="$t('faq-q-5')" />
      <p v-html="$t('faq-a-5')" />
    </main>
    <footer></footer>
  </div>
</template>

<i18n>
{
  "en": {
    "faq-q-1": "What is this app about?",
    "faq-a-1": "We're trying to make KAIST a better place. We want to collect everyone's diverse ideas. What do you think would make life on campus better?",
    "faq-q-2": "Why should I participate?",
    "faq-a-2": "You can have an impact on improving conditions for everyone. We are also preparing several rewards for good ideas and active contributors. We will share the details with you later, but rest assured all active participants are always eligible for all rewards.",
    "faq-a-2-autonomy": "You can have a real impact on improving conditions for everybody! Among all ideas submitted until April 11, we will hand-pick three promising ideas, present them to the whole school, and follow up with concrete steps to support their implementation. As part of our study, we also consider other rewards. We cannot show you that right now, but all active participants will always be eligible for all rewards.",
    "faq-a-2-control": "You can have a real impact on improving conditions for everybody! Furthermore, among all active participants we select 10 members to win $20! As part of our study, we also consider other rewards.  We cannot show you that right now, but all active participants will always be eligible for all rewards.",
    "faq-q-3": "What do you do with my data?",
    "faq-a-3": "We take privacy very seriously. Your personal information will not be shared with third parties. All data collected in this app will only be published in anonymized form. The data will be used for our research about design of voluntary participation apps. All personally identifiable data will be destroyed after the end of the study.",
    "faq-q-4": "Who's behind this?",
    "faq-a-4": "This is a reseacrh project from <a href='http://kixlab.org' target='_blank'>KIXLAB</a> at KAIST School of Computing. We are advised by Prof. Juho Kim.",
    "faq-q-5": "I have more questions.",
    "faq-a-5": "Don't hesitate to contact us any time! The easiest is by email: <a href='mailto:grau@kaist.ac.kr'>grau@kaist.ac.kr</a>."
  },
  "ko": {
    "faq-q-1": "이 응용 프로그램은 무엇에 관한 것인가요?",
    "faq-a-1": "우리는 KAIST를 더 나은 곳으로 만들기 위해 노력하고 있습니다. 우리는 모든 사람들의 다양한 아이디어를 수집하고자합니다. 캠퍼스에서 더 나은 삶을 살 수 있다고 생각하니?",
    "faq-q-2": "왜 참여할까요?",
    "faq-a-2": "모든 사람의 상태를 개선하는 데 영향을 미칠 수 있습니다. 또한 훌륭한 아이디어와 적극적인 기부자에게 여러 가지 보상을 준비하고 있습니다. 나중에 세부 사항을 알려 드리지만 적극적인 참가자는 항상 모든 보상을받을 수 있습니다.",
    "faq-a-2-autonomy": "당신은 영원히를위한 상태 개선에 진짜 영향을 미칠 수 있습니다! 4 월 11 일까지 제출 된 모든 아이디어 중에서 3 가지 유망한 아이디어를 직접 선택하여 전체 학교에 발표하고 구현을 지원하기위한 구체적인 단계를 수행합니다. 우리 연구의 일환으로 다른 보상도 고려합니다. 지금 당장은 그 사실을 보여줄 수는 없지만 모든 활동적인 참가자는 항상 모든 보상을받을 자격이 있습니다.",
    "faq-a-2-control": "당신은 영원히를위한 상태 개선에 진짜 영향을 미칠 수 있습니다! 또한, 모든 적극적인 참가자들 중 10 명을 선택하여 20 달러를 얻습니다! 우리 연구의 일환으로 다른 보상도 고려합니다. 지금 당장은 그 사실을 보여줄 수는 없지만 모든 활동적인 참가자는 항상 모든 보상을받을 자격이 있습니다.",
    "faq-q-3": "내 데이터로 뭐 해요?",
    "faq-a-3": "우리는 프라이버시를 매우 중요하게 생각합니다. 귀하의 개인 정보는 제 3 자와 공유되지 않습니다. 이 앱에서 수집 된 모든 데이터는 익명으로 게시됩니다. 이 데이터는 자발적 참여 앱 디자인에 대한 우리 연구에 사용될 것입니다. 모든 개인 식별 데이터는 연구가 끝난 후에 폐기됩니다.",
    "faq-q-4": "이 프로젝트를 진행하는 사람이 누구에요?",
    "faq-a-4": "카이스트 전산학부 <a href='http://kixlab.org' target='_blank'>KIXLAB</a>에서 진행하는 연구 프로젝트입니다. 지도 교수님은 김주호 교수님입니다.",
    "faq-q-5": "더 많은 질문 이있어요.",
    "faq-a-5": "언제든지 저희에게 연락 주저하지 마세요! 가장 쉬운 방법은 이메일이에요: <a href='mailto:grau@kaist.ac.kr'>grau@kaist.ac.kr</a>."
  }
}
</i18n>

<script>
import MenuIcon from "icons/menu";
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  name: 'FAQ',
  components: {
    MenuIcon,
  }
};
</script>

<style scoped>
.content {
  padding: 1em;
}
.question {
  font-weight: bold;
  margin-bottom: 0;
}
</style>
