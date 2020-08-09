"""
This file defines some test fixtures that our unit tests can use.

All of our unit tests will get access to these fixtures automatically. (Pytest
treats the name `conftest.py` specially.)
"""

import mariadb

import pytest

import cultural_touchstones

def clear_database(app):
    """
    Given an instance of the Cultural Touchstones app, remove all of the data
    from the database.

    (The table structure is kept intact.)
    """
    mariadb.connect(
        user=app.config['DB_USER'],
        password=app.config['DB_PASSWORD'],
        host=app.config['DB_HOST'],
        port=app.config['DB_PORT'],
        database=app.config['DB_NAME'],
    ).cursor().execute("""
        TRUNCATE TABLE watchlist_items;
    """)


@pytest.fixture
def client():
    """
    Provide a Flask test client to any unit test that asks for it.
    """
    app = cultural_touchstones.create_app({
        'TESTING': 'true',
        'DB_USER': 'test_user',
        'DB_NAME': 'testing',
        'DB_PASSWORD': 'testpasswordnotactuallyasecret',
    });
    clear_database(app);
    with app.test_client() as client:
        yield client
