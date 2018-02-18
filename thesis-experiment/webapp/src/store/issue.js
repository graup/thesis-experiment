import { apiGet } from '../utils/api';

export default {
  state: {
    issue_ids: [],
    issues_by_id: {},
    issues_by_slug: {},
  },
  getters: {
  },
  mutations: {
    setIssue(state, issue) {
      state.issues_by_id[issue.id] = issue;
    },
    setIssues(state, issues) {
      issues.forEach((issue) => {
        state.issues_by_id[issue.id] = issue;
        state.issues_by_slug[issue.slug] = issue;
        if (state.issue_ids.indexOf(issue.id) === -1) {
          state.issue_ids.push(issue.id);
        }
      });
    },
  },
  actions: {
    getIssue(context, payload) {
      // Try to return already fetched data
      if (context.state.issues_by_slug[payload.slug]) {
        return new Promise((resolve) => {
          resolve(context.state.issues_by_slug[payload.slug]);
        });
      }
      // fetch new data
      return context.dispatch('fetchIssue', payload);
    },
    getIssues(context, payload) {
      // Try to return already fetched data
      if (context.state.issue_ids.length) {
        return new Promise((resolve) => {
          resolve(context.state.issue_ids.map(id => context.state.issues_by_id[id]));
        });
      }
      // fetch new data
      return context.dispatch('fetchIssues', payload);
    },
    fetchIssue({ commit }, { slug }) {
      return new Promise((resolve, reject) => {
        apiGet(`issues/${slug}/`).then((response) => {
          // Update store and resolve promise
          commit('setIssue', response.data);
          resolve(response.data);
        }).catch(reject);
      });
    },
    fetchIssues({ commit }) {
      return new Promise((resolve, reject) => {
        apiGet('issues/').then((response) => {
          // Update store and resolve promise
          commit('setIssues', response.data.results);
          resolve(response.data.results);
        }).catch(reject);
      });
    },
  },
};
