<template>
  <div class="viewport post-issue has-header">
    <Sheet ref="sheet">
      <div class="loading" v-if="locationLoading">
        <Spinner />
        Finding places near you...
      </div>
      
      <div v-if="errors.location">
        <p class="error">{{errors.location.join(' ')}}</p>
        <my-button text="Try again" v-on:click.native.capture="showNearPlaces" />
        <my-button text="Cancel" v-on:click.native.capture="$refs.sheet.hide()" primary={true} />
      </div>

      <div v-if="nearPlaces.length">
        <p>Select a place related to this idea</p>
        <ul class="near-places-list">
          <li v-for="place in nearPlaces" v-bind:key="place.id" v-on:click="selectPlace(place)">
            <span class="distance">{{Math.round(place.distance*1000)}}m</span>
            {{place.tags.name}}
          </li>
        </ul>
        <my-button text="Cancel" v-on:click.native.capture="$refs.sheet.hide()" primary={true} />
      </div>
    </Sheet>


    <header>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
      <div class="view-title">New Idea</div>
      <div class="icon-button" v-on:click="goBack"><ChevronLeftIcon /></div>
    </header>
    <main class="content">
      <p class="intro">
        Everybody has great ideas that our community can benefit from.
        Tell us what you think!
      </p>

      <div class="form-wrapper form-wide">
        <form action="" class="form">
          <div class="form-group">
            <input id="title" class="form-input" type="text" v-model="title" required />
            <label class="form-label" for="title">Title</label>
            <div class="error" v-if="errors.title">{{errors.title.join(' ')}}</div>
          </div>
          <div class="form-group">
            <textarea id="text" class="form-input" v-model="text" required></textarea>
            <label class="form-label" for="text">Description</label>
            <div class="error" v-if="errors.text">{{errors.text.join(' ')}}</div>
          </div>
          <div class="form-group">
            <p>Attachments</p>
            <my-button text="Location" v-on:click.native.capture="showNearPlaces" icon={true}><LocationIcon /></my-button>
            {{location}}
          </div>
          <div class="form-group button-group vertical spaced" style="max-width: 200px;">
            <my-button text="Continue" primary={true} v-on:click.native.capture="createIssue" />
          </div>
        </form>
      </div>

    </main>
    <footer></footer>
  </div>
</template>

<script>
import ChevronLeftIcon from "icons/chevron-left";
import LocationIcon from "icons/map-marker";
import {navigationMixins} from "@/mixins";
import {getPlacesAroundPoint} from "@/utils/geo";
import Sheet from "@/components/elements/Sheet";
import Spinner from '@/components/elements/Spinner';

export default {
  mixins: [navigationMixins],
  components: {
    ChevronLeftIcon,
    LocationIcon,
    Sheet,
    Spinner,
  },
  data() {
    return {
      title: '',
      text: '',
      location: '',
      categories: [1],
      errors: {},
      loading: false,
      nearPlaces: [],
      locationLoading: false,
    };
  },
  methods: {
    createIssue() {
      this.$data.loading = true;
      const data = { title: this.$data.title, text: this.$data.text, categories: this.$data.categories };
      this.$store.dispatch('createIssue', { issue: data }).then((issue) => {
        this.$router.push({ name: 'issue-detail', params: { slug: issue.slug, item: issue }});
      }).catch(error => {
        this.$data.errors = error.response.data;
        this.$data.loading = false;
      });
    },
    showNearPlaces() {
      if (this.locationLoading || this.nearPlaces.length) {
        // still loading or already loaded
        this.$refs.sheet.show();
        return;
      }
      if (navigator.geolocation) {
        this.locationLoading = true;
        this.nearPlaces = [];
        this.errors.location = null;
        this.$refs.sheet.show();
        navigator.geolocation.getCurrentPosition((position) => {
          getPlacesAroundPoint(position.coords.latitude, position.coords.longitude).then((places) => {
            this.nearPlaces = places;
            this.locationLoading = false;
          });
        }, (error) => {
          let msgs = {
            [error.PERMISSION_DENIED]: "You denied getting access to your location.",
            [error.POSITION_UNAVAILABLE]: "Your location information is unavailable.",
            [error.TIMEOUT]: "Finding your location is taking too long.",
            [error.UNKNOWN_ERROR]: "An unknown error occurred.",
          }
          this.errors.location = [msgs[error.code]];
          this.locationLoading = false;
        }, {
          enableHighAccuracy: false,
          timeout: 60000,
          maximumAge: 60*1000
        });
      }
    },
    selectPlace(place) {
      this.location = place.tags.name;
      this.$refs.sheet.hide();
    },
  },
};
</script>

<style lang="scss" scoped>
.intro {
  padding: 0 2em;
  margin: 1rem 0;
  text-align: center;
}
textarea {
  height: 150px;
}
.near-places-list {
  list-style: none;
  margin: 0 0 20px 0;
  padding: 0;

  li {
    line-height: 40px;
    border-bottom: 1px solid #eee;
    text-align: left;
    cursor: pointer;

    .distance {
      float: right;
      color: #999;
      font-size: 90%;
    }
  }
}
</style>
