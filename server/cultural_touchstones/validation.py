"""
This file contains some methods for validating input from HTTP Requests.
"""

MAX_WATCHLIST_ITEM_LENGTH = 300

def is_list_of_strings(value):
    """
    Return whether a value is a list of strings.

    Subclasses of lists or strings are also acceptable.

    >>> is_list_of_strings(["Do", "Re", "Mi"])
    True

    >>> is_list_of_strings([b"Do", b"Re", b"Mi"])
    False

    >>> is_list_of_strings({"Do": 0, "Re": 2, "Mi": 4})
    False

    >>> is_list_of_strings(529)
    False

    Usually, we would rely on duck-typing rather than check an object's class
    directly. However, for API endpoints, it's important that people are using
    exactly the right types. For example, we wouldn't want to let somebody pass
    off a dictionary as a list, because we can't guarrantee that we'll support
    that in the future.
    """
    return (
        isinstance(value, list)
            and all(isinstance(item, str) for item in value)
    )

def is_short_enough(watchlist_item):
    """
    Return whether the watchlist item, a string, fits in the database.

    >>> is_short_enough('a')
    True

    >>> is_short_enough('a' * MAX_WATCHLIST_ITEM_LENGTH)
    True

    >>> is_short_enough('a' * MAX_WATCHLIST_ITEM_LENGTH + '!')
    False

    >>> is_short_enough('\U00010000' * MAX_WATCHLIST_ITEM_LENGTH)
    True

    Watchlist items can fit in the database iff their length is less than or
    equal to MAX_WATCHLIST_ITEM_LENGTH. (Here, string length is measured as the
    number of UTF-8 code points.)
    """
    return len(watchlist_item) <= MAX_WATCHLIST_ITEM_LENGTH
