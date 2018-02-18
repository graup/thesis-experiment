<template>
  <div id="app">
    <side-menu />
    <transition :name="transitionName" :duration="500">
      <router-view class="child-view" v-bind:class="{'menu-opened': isMenuOpened}" />
    </transition>
  </div>
</template>

<script>
import 'normalize.css';
import SideMenu from '@/components/elements/SideMenu';
import {navigationMixins} from "@/mixins";

export default {
  mixins: [navigationMixins],
  name: 'App',
  data () {
    return {
      transitionName: 'slide-left',
    }
  },
  watch: {
    '$route' (to, from) {
      const toDepth = to.path.split('/').length
      const fromDepth = from.path.split('/').length
      let goingUp = false;
      if (toDepth < fromDepth || to.path == '/') {
        goingUp = true;
      }
      this.transitionName = goingUp ? 'slide-right' : 'slide-left'
    }
  },
  components: {
    'side-menu': SideMenu,
  },
};
</script>

<style lang="scss">
@import url('https://fonts.googleapis.com/css?family=Patua+One|Raleway:300,500,600');

body {
  background-color: #e7e7e7;
}
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  margin-top: 60px;

  max-width: 375px; /* for testing mobile layout */
  margin: 0 auto;

  position: relative;
  background-color: #f4f4f4;

  overflow-x: hidden;

  .white {
    background-color: #fff;
  }
}
/* sticky footer */
.viewport {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}
.content {
  flex: 1;
}
/* general typo */
p {
  line-height: 1.5;
  margin: 0 0 1em;
}
a {
  text-decoration: none;
}
/* buttons etc */
.icon-button {
  font-size: 120%;
  padding: 5px;
  cursor: pointer;
  line-height: 1;

  svg {
    vertical-align: middle;
  }
}
/* header */
header {
  display: flex;
  align-items: center;
  background-color: #d8d8d8;

  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 99;
  transition: all .2s;

  .view-title {
    /*flex: 1;*/
    text-align: center;
    line-height: 45px;
    font-weight: bold;
    text-transform: uppercase;
  }

  > :first-child {
    margin-right: auto;
  }
  > :last-child {
    /* put a copy of the first item here to achieve equal margins */
    margin-left: auto;
    visibility: hidden;
  }

}
.viewport.has-header {
  main {
    margin-top: 45px;
  }
}

/* forms */
.form-wrapper {
  max-width: 30%;
  min-width: 300px;
  padding: 50px 2rem 50px 2rem;
  box-sizing: border-box;
  margin: 50px auto;   
  background-color: #ffffff;
  border-radius: 4px;
  box-shadow: 0 10px 25px rgba(50,50,93,.1),0 5px 5px rgba(0,0,0,.07);
}

.form-group {
  position:relative;  

  & + .form-group {
    margin-top: 30px;
  }
}

.form-label {
  position: absolute;
  left: 0;
  top: 10px;
  color: #999;
  background-color: #fff;
  z-index: 10;
  transition: transform 150ms ease-out, font-size 150ms ease-out;
}

:focus + .form-label,
:valid + .form-label {
  transform: translateY(-125%);
  font-size: .75em;
}

.form-input {
  position: relative;
  padding: 12px 0px 5px 0;
  width: 100%;
  outline: 0;
  border: 0;
  box-shadow: 0 1px 0 0 #e5e5e5;
  transition: box-shadow 150ms ease-out;
  
  &:focus {
    box-shadow: 0 2px 0 0 #386b8d;
  }
}

.form-input.filled {
  box-shadow: 0 2px 0 0 lightgreen;
}



/* page transitions */
.fade-enter-active, .fade-leave-active {
  transition: opacity .5s ease;
}
.fade-enter, .fade-leave-active {
  opacity: 0
}

.child-view > * {
  transition: all .5s cubic-bezier(.55,0,.1,1);
}
.slide-left-enter > *, .slide-right-leave-active > *  {
  opacity: 0;
  transform: translate(50px, 0);
}
.slide-left-leave-active > * , .slide-right-enter > *  {
  opacity: 0;
  transform: translate(-50px, 0);
}

.viewport.menu-opened > * {
  transform: translateX(200px);
}
</style>
