<template>
  <div class="side-menu" v-bind:class="{opened: isMenuOpened}">
    <app-logo instance-name="KAIST" class="small inverted" />

    <ul class="menu-items" v-if="isAuthenticated">
      <li><a class="menu-item" v-on:click="gotoRoute('feed')">Recent Issues</a></li>
      <li><a class="menu-item" v-on:click="gotoRoute('feed')">Recent Issues</a></li>
      <li><a class="menu-item" v-on:click="gotoRoute('feed')">Recent Issues</a></li>
      <li><a class="menu-item" v-on:click="logout">Logout</a></li>
    </ul>
    <ul class="menu-items" v-if="!isAuthenticated">
      <li><a class="menu-item" v-on:click="$router.push('login')">Log in</a></li>
      <li><a class="menu-item" v-on:click="$router.push('signup')">Sign up</a></li>
    </ul>

    <div class="authentication-status" v-if="isAuthenticated">
      Logged in as {{user.username}}.
      <div class="token">{{authToken}}</div>
    </div>
  </div>
</template>

<script>
import {navigationMixins} from "@/mixins";


export default {
  mixins: [navigationMixins],
  name: 'side-menu',
  props: ['instanceName'],
  data() {
    return {
      user: {},
    };
  },
  created () {
    this.$store.dispatch('getCurrentUser').then(user => {
      this.$data.user = user;
    })
  },
  methods: {
    gotoRoute(path) {
      this.$store.commit('setMenuOpened', false);
      this.$router.push(path);
    },
  },
};
</script>

<style lang="scss">
.side-menu {
  position: fixed;
  z-index: 100;
  top: 0;
  left: 0;
  min-height: 100vh;
  width: 200px;
  background-color: #333;
  color: #fff;

  text-align: center;

  transition: all .5s cubic-bezier(.55,0,.1,1);
  transform: translateX(-100%);

  &.opened {
    transform: translateX(0%);
  }
}

.menu-items {
  list-style: none;
  margin: 0;
  padding: 0 1rem;

  li {
    border-bottom: 1px solid #666;

    &:last-child {
      border-bottom: none;
    }
  }
}
.menu-item {
  display: block;
  line-height: 2.5;
  cursor: pointer;
}

.token {
  width: 100%;
  text-overflow: ellipsis;
  overflow: hidden;
}
</style>
