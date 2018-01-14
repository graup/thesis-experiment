from flask import Flask, make_response, render_template, session, url_for, request, redirect
from gcos import vignette, score_test
from collections import defaultdict
import os
import uuid
import json
from random import randint

app = Flask(__name__)
app.config['DEBUG'] = True

def balanced_latin_squares(n):
    l = [[((j//2+1 if j%2 else n-j//2) + i) % n + 1 for j in range(n)] for i in range(n)]
    if n % 2:  # Repeat reversed for odd n
        l += [seq[::-1] for seq in l]
    return l

conditions = ('A', 'I', 'C', 'BL')
combinations = (
    ('I', 'C'),
    ('A', 'BL'),
    ('I', 'BL'),
    ('C', 'A'),
    ('I', 'A'),
    ('C', 'BL'),
)
orderings = balanced_latin_squares(6)

def save_session(session):
    filename = 'data/%s.json' % session['user_id']
    data = dict(session)
    data['user_id'] = str(data['user_id'])
    with open(filename, 'w') as fp:
        json.dump(data, fp)

@app.before_request
def before_request():
    "Ensure user id in session"
    if not session.get('user_id', None):
        user_id = uuid.uuid1()
        session['user_id'] = user_id
    if not session.get('user_counter', None):
        session['user_counter'] = app.user_counter
        app.user_counter += 1

@app.route('/')
def start():
    "Start page and create session id"
    context = {}
    
    context['user_id'] = session['user_id']
    resp = make_response(render_template('start.html', **context))
    return resp

@app.route('/pre-test', methods=['GET', 'POST'])
def gcos():
    "Pre-test"
    context = {'vignette': vignette}
    if request.method == 'POST':
        ratings = defaultdict(lambda: defaultdict(dict))
        for key in request.form:
            _, question, answer = key.split('_')
            ratings[question][answer] = int(request.form[key])
        session['test_scores'] = score_test(ratings)
        save_session(session)
        return redirect(url_for('comparison'))
    resp = make_response(render_template('gcos.html', **context))
    return resp

@app.route('/comparison', methods=['GET', 'POST'])
def comparison():
    "Comparison"
    if request.method == 'POST':
        session['comparisons'] = request.form
        save_session(session)
        return redirect(url_for('finish'))
    context = {'test_scores': session['test_scores'], 'user_counter': session['user_counter']}
    # Get the ordering of pairs per balanced latin square
    ordering = orderings[ session['user_counter'] % len(orderings) ]
    comparison_pairs = [{'items': list(combinations[item-1])} for item in ordering]
    for pair in comparison_pairs:
        second_order = randint(0, 1)
        pair['order'] = second_order
        pair['key'] = '_'.join(pair['items'])
        if second_order == 1:
            # Reverse order in 50% of the time
            pair['items'] = list(pair['items'][::-1])
    context['comparison_pairs'] = comparison_pairs
    session['comparison_pairs'] = comparison_pairs
    resp = make_response(render_template('comparison.html', **context))
    return resp

@app.route('/finish', methods=['GET', 'POST'])
def finish():
    "Finish and get email optionally"
    context = {}
    if request.method == 'POST':
        session['email'] = request.form['email']
        save_session(session)
        context['saved'] = True
    resp = make_response(render_template('finish.html', **context))
    return resp

@app.context_processor
def override_url_for():
    return dict(url_for=dated_url_for)

def dated_url_for(endpoint, **values):
    if endpoint == 'static':
        filename = values.get('filename', None)
        if filename:
            file_path = os.path.join(app.root_path,
                                     endpoint, filename)
            values['q'] = int(os.stat(file_path).st_mtime)
    return url_for(endpoint, **values)

if __name__ == '__main__':
    app.secret_key = '7654321§ckl;765r263gy'
    app.user_counter = 0
    app.run(threaded=True)