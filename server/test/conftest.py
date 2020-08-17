"""
This file defines some test fixtures that our unit tests can use.

All of our unit tests will get access to these fixtures automatically. (Pytest
treats the name `conftest.py` specially.)
"""

import collections

import mariadb

import pytest

import cultural_touchstones
from cultural_touchstones.db import MAX_WATCHLIST_ITEM_LENGTH

# This class represents one of the rows in the 'watchlist-items' database
# table.
WatchlistItem = collections.namedtuple('WatchlistItem', 'position contents')

def _database_connection(app):
    """
    Given an instance of the Flask app, return a connection to its database.

    This connection observes all of the app's configuration options.

    The caller is in charge of closing the connection when they're done with
    it.
    """
    return mariadb.connect(
        user=app.config['DB_USER'],
        password=app.config['DB_PASSWORD'],
        host=app.config['DB_HOST'],
        port=app.config['DB_PORT'],
        database=app.config['DB_NAME'],
    )

def _clear_database(app):
    """
    Given an instance of the app, remove all of the data from the database.

    (The table structure is kept intact.)
    """
    with _database_connection(app) as connection:
        connection.cursor().execute(
            """
            TRUNCATE TABLE watchlist_items;
            """,
        )

def _insert_watchlist_items(app, items):
    """
    Given an instance of the app, add some watchlist items to the database.

    Here, `items` is an iterable of WatchlistItem instances.
    """
    # MariaDB is picky about the types it's given. It needs a list of real
    # tuples; named tuples aren't good enough.
    items = [tuple(item) for item in items]
    with _database_connection(app) as connection:
        connection.cursor().executemany(
            """
            INSERT INTO watchlist_items (position, contents)
                VALUES (?, ?);
            """,
            items
        )


@pytest.fixture
def _app():
    """
    Provide an instance of the Cultural Touchstones app configured for testing.
    """
    yield cultural_touchstones.create_app({
        'TESTING': 'true',
        'DB_USER': 'test_user',
        'DB_NAME': 'testing',
        'DB_PASSWORD': 'testpasswordnotactuallyasecret',
    })


@pytest.fixture
def empty_client(_app):
    """
    Provide a Flask test client with an initially empty database.
    """
    _clear_database(_app)
    with _app.test_client() as client:
        yield client

@pytest.fixture
def client_with_data(_app):
    """
    Provide a Flask test client whose database contains some initial data.

    This function returns a tuple of two values.

    The first value is the Flask test client, configured to talk to the test
    database, which will contain some initial data.

    The second value is the data contained in the database, in the form of a
    list of WatchlistItem instances.
    """
    test_data = [
        WatchlistItem(position, contents)
        for position, contents in enumerate([
            'The Castle of Cagliostro',
            'Nausicaä of the Valley of the Wind',
            '',
            '.' * MAX_WATCHLIST_ITEM_LENGTH,
            # Test the Santa emoji, since it's an astral-plane character.
            '🎅' * MAX_WATCHLIST_ITEM_LENGTH,
        ])
    ]
    _clear_database(_app)
    _insert_watchlist_items(_app, test_data)
    with _app.test_client() as client:
        yield client, test_data
