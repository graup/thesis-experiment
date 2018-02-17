import json
import glob, os
import csv
from experiment import get_top_preference, orderings
from gcos import normalize_score
csvfile =  open('data/preferences.csv', 'w', newline='')
writer = csv.writer(csvfile, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)

csvfile2 =  open('data/data.csv', 'w', newline='')
writer2 = csv.writer(csvfile2, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)     

csvfile3 =  open('data/uncoded.csv', 'w', newline='')
writer3 = csv.writer(csvfile3, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)  
    
#header = ['subject', 'duration', 'test_A', 'test_C', 'test_I', 'item_1', 'item_2', 'result', 'order', 'pair_order']
pairs = ['A_I', 'A_C', 'I_C', 'A_BL', 'I_BL', 'C_BL']
test_keys = ('A','C','I',)
header = pairs + ['test', ] + ['test_A', 'test_C', 'test_I',] + ['duration', 'order']
print(header)
writer.writerow(header)

test_score_categories = []

data_header = ['duration', 'order', 'pair_order', 'preferred', 'test_max'] + ['test_A', 'test_C', 'test_I',] + ['testabs_A', 'testabs_C', 'testabs_I',] + ['result_correct', 'result_reason', 'rationale_correct', 'open']
writer2.writerow(data_header)

for filename in glob.glob("data/*.json"):
    row = []
    with open(filename) as data_file:    
        data = json.load(data_file)
        if not 'comparisons' in data:
            continue
        #print(data)
        
        #for version in ('A', 'I', 'C', 'BL',):
        #    row.append(2*sum([1 for item in data['comparisons'].items() if item[1] == version]) - 3)
        
        for pair in pairs:
            result = data['comparisons'][pair]
            a, b = pair.split('_')
            numeric = 1 if result == a else -1
            #numeric = 0 if result == a else 1
            row.append(numeric)
        #(12) (13) (23) (14) (24) (34) (15) (25) 

        order = 1 + data['user_counter']%len(orderings)
        pair_orders = [pair['pair_order'] for pair in data.get('comparison_pairs', [])]
        pair_order = 'o' + ''.join(map(str, pair_orders))

        if 'finished' in data:
            duration = int(data['finished'] - data['started'])
        else:
            duration = 0
        #row.append(data['user_counter'])
        #row.append(duration)
        test_scores_sorted = sorted(data['test_scores'].items(), key=lambda item: item[1])[::-1]
        test_scores_order = '>'.join([item[0] for item in test_scores_sorted])
        if test_scores_order not in test_score_categories:
            test_score_categories.append(test_scores_order)
        row.append(1+test_score_categories.index(test_scores_order))

        test_scores_values = [data['test_scores'][key] for key in test_keys]
        test_scores_values_norm = [normalize_score(score) for score in test_scores_values]
        
        row = row + test_scores_values_norm + [duration, order]
        print(filename[:16])
        print(row)
        writer.writerow(row)
        survey = data.get('survey', {})
        writer2.writerow([
            duration,
            order,
            pair_order,
            get_top_preference(data['comparisons'])]
            + [test_scores_sorted[0][0]] + test_scores_values_norm + test_scores_values + [
            survey.get('result_correct'),
            survey.get('result_reason'),
            survey.get('rationale_correct'),
            survey.get('open')
        ])

        #writer3.writerow([survey.get('result_reason'), survey.get('open')])
        writer3.writerow([survey.get('result_reason')])

print('Labels for test (category column)', test_score_categories)