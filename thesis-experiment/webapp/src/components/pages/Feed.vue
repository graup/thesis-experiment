<template>
  <div class="viewport feed has-header">
    <header>
      <div class="icon-button" v-on:click="toggleMenu">
        <MenuIcon />
      </div>
      <div class="view-title">Recent Ideas</div>
    </header>
    <main class="content">

      <p class="intro">
        Welcome!
      </p>

    </main>
    <footer></footer>
  </div>
</template>

<script>
import MenuIcon from "icons/menu";
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  components: {
    MenuIcon
  },
};
</script>

<style scoped>
.feed {
  background-color: #fff;
}
</style>
