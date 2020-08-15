"""
This file contains some utility functions for working with basic Python values.
"""

def flatten(iterable):
    """
    Turn a nested iterable of items into a flat iterable of items.

    (If you have an iterable nested several levels deep, this This function
    only flattens the top level; it doesn't recursively flatten the iterables.)

    >>> list(flatten([
    ...     ['a', 'b', 'c'],
    ...     ['d', 'e', 'f'],
    ... ]))
    ['a', 'b', 'c', 'd', 'e', 'f']

    >>> list(flatten([
    ...    [[1], [2]],
    ...    [[3, 4]],
    ... ]))
    [[1], [2], [3, 4]]

    >>> list(flatten(iter([
    ...     'abc',
    ...     (ord(letter) for letter in 'def'),
    ... ])))
    ['a', 'b', 'c', 100, 101, 102]

    >>> list(flatten([]))
    []
    """
    return (item for subiterable in iterable for item in subiterable)
