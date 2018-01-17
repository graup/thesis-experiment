import json
import glob, os
import csv
csvfile =  open('data/preferences.csv', 'w', newline='')
writer = csv.writer(csvfile, delimiter=';', quotechar='"', quoting=csv.QUOTE_MINIMAL)    

    
#header = ['subject', 'duration', 'test_A', 'test_C', 'test_I', 'item_1', 'item_2', 'result', 'order', 'pair_order']
pairs = ['A_I', 'A_C', 'I_C', 'A_BL', 'I_BL', 'C_BL']
header = pairs + ['test', ]
print(header)
writer.writerow(header)

test_score_categories = []

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

        

        """
        for pair in data.get('comparison_pairs', []):
            key = pair['key']
            result = data['comparisons'].get(key)
            cells = row + key.split('_')
            cells.append(result)
            cells.append(pair['order'])
            cells.append(pair['pair_order'])
            print(cells)
        """

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

        print(row)
        writer.writerow(row)

print('Labels for test (category column)', test_score_categories)