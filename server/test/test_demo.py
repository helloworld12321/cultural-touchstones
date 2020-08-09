"""
These are some temporary tests whose main job are to ensure that pytest is set
up correctly, that we can talk to the database, that we can import the project,
and things like that.
"""


def test_empty_db(client):
    """
    Make sure that the database used for testing is initially empty.
    """
    rv = client.get('/demo/watchlist-items')
    assert rv.json == []
