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

      <p class="question">What is this app about?</p>
      <p>We're trying to make KAIST a better place. We want to collect everyone's diverse ideas. What do you think would make life on campus better?</p>

      <p class="question">Why should I participate?</p>
      <p>You can have a real impact on improving conditions for everbody! Among all ideas submitted until April 8, we will hand-pick a number of promising ideas, present them to everyone, and follow up with concrete steps to support their implementation.</p>

      <p class="question">What do you do with our data?</p>
      <p>We take privacy seriously. Your data will not be shared with third parties.
        We will use data collected in this app in anonymized form for in our research about design of voluntary participation apps.</p>
      
      <p class="question">Who's behind this?</p>
      <p>My name is Paul, and I'm a member of <a href="http://kixlab.org" target="_blank">KIXLAB</a> at KAIST School of Computing. My advisor is Prof. Juho Kim.</p>

      <p class="question">I have more questions.</p>
      <p>Don't hesitate to contact us any time! The easiest is by email: <a href="mailto:grau@kaist.ac.kr">grau@kaist.ac.kr</a></p>
    </main>
    <footer></footer>
  </div>
</template>

<i18n>
{

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
