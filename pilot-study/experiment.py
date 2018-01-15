from itertools import combinations
from random import randint

def balanced_latin_squares(n):
    "Source: https://medium.com/@graycoding/balanced-latin-squares-in-python-2c3aa6ec95b9"
    l = [[((j//2+1 if j%2 else n-j//2) + i) % n for j in range(n)] for i in range(n)]
    if n % 2:  # Repeat reversed for odd n
        l += [seq[::-1] for seq in l]
    return l

conditions = ('A', 'I', 'C', 'BL')
pairs = list(combinations(conditions, 2))
orderings = balanced_latin_squares(len(pairs))

def get_ordering(n):
    "Return ordering sequence based on some number that is fixed per user (user_id or counter)"
    return orderings[n % len(orderings)]

def get_ordered_pairs(ordering):
    "Return the comparison pairs in the specified order"
    return [list(pairs[idx]) for idx in ordering]

def shuffle_pair_random(pair):
    "Reverse order of a pair in 50% of the time"
    order = randint(0, 1)
    if order == 1:
        pair = list(pair[::-1])
    return pair, order