"""
This file tests the endpoints in the "watchlist" blueprint.
"""

def test_GET_watchlist_returns_an_empty_list_when_the_database_is_empty(empty_client):
    assert empty_client.get('/watchlist').json == []

def test_GET_watchlist_returns_a_list_of_the_contents_of_the_watchlist_items(client_with_data):
    client, data = client_with_data
    expected_json = [
        item.contents
        for item in sorted(data, key=lambda item: item.position)
    ]
    assert client.get('/watchlist').json == expected_json
