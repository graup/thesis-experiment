import { apiGet, apiPost } from '../utils/api';

export default {
  state: {
    issue_ids: [],
    issues_by_id: {},
    issues_by_slug: {},
    loaded_issues: false,
    loaded_comments: {},
    comments_by_issue_slug: {},
  },
  getters: {
  },
  mutations: {
    setIssue(state, { issue }) {
      state.issues_by_id[issue.id] = issue;
    },
    addIssue(state, { issue }) {
      state.issues_by_id[issue.id] = issue;
      state.issue_ids = [issue.id, ...state.issue_ids];
    },
    setIssues(state, issues) {
      issues.forEach((issue) => {
        state.issues_by_id[issue.id] = issue;
        state.issues_by_slug[issue.slug] = issue;
      });
      state.issue_ids = issues.map(issue => issue.id);
      state.loaded_issues = true;
    },
    setComments(state, { slug, comments }) {
      state.comments_by_issue_slug[slug] = comments;
      state.loaded_comments[slug] = true;
    },
    markCommentsDirty(state, { slug }) {
      state.loaded_comments[slug] = false;
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
      if (context.state.loaded_issues) {
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
          commit('setIssue', { issue: response.data });
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
    createIssue({ commit }, { issue }) {
      return new Promise((resolve, reject) => {
        apiPost('issues/', issue).then((response) => {
          // Update store and resolve promise
          commit('addIssue', {
            issue: response.data,
            meta: {
              analytics: [['event', 'issue', 'create', response.data.slug]],
            },
          });
          resolve(response.data);
        }).catch(reject);
      });
    },
    likeIssue({ commit }, { issue }) {
      return new Promise((resolve, reject) => {
        apiPost(`issues/${issue.slug}/like/`, { liked: issue.user_liked }).then(() => {
          commit('setIssue', {
            issue,
            meta: {
              analytics: [['event', 'issue', issue.user_liked ? 'like' : 'unlike', issue.slug]],
            },
          });
          resolve(issue);
        }).catch(reject);
      });
    },
    flagIssue({ commit }, { issue, reason }) {
      return new Promise((resolve, reject) => {
        apiPost(`issues/${issue.slug}/flag/`, { reason }).then(() => {
          commit('setIssue', {
            issue,
            meta: {
              analytics: [['event', 'issue', 'flag', issue.slug]],
            },
          });
          resolve();
        }).catch(reject);
      });
    },
    getComments(context, { slug }) {
      // Try to return already fetched data
      if (context.state.loaded_comments[slug]) {
        return new Promise((resolve) => {
          resolve(context.state.comments_by_issue_slug[slug]);
        });
      }
      // fetch new data
      return context.dispatch('fetchComments', { slug });
    },
    fetchComments({ commit }, { slug }) {
      return new Promise((resolve, reject) => {
        apiGet(`issues/${slug}/comments/`).then((response) => {
          // Update store and resolve promise
          commit('setComments', { slug, comments: response.data });
          resolve(response.data);
        }).catch(reject);
      });
    },
    createComment({ dispatch, commit, state }, { comment, slug }) {
      return new Promise((resolve, reject) => {
        apiPost('comments/', comment).then((response) => {
          // Update store and resolve promise
          commit('setComments', {
            slug,
            comments: [response.data, ...state.comments_by_issue_slug[slug]],
            meta: {
              analytics: [['event', 'comment', 'create', slug]],
            },
          });
          // Reload comments
          dispatch('fetchComments', { slug });
          resolve(response.data);
        }).catch(reject);
      });
    },
  },
};
