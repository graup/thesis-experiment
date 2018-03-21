import client from './http';

function apiGet(url, params) {
  return client.get(url, params);
}

function apiPost(url, params) {
  return client.post(url, params);
}

export {
  apiGet,
  apiPost,
};
