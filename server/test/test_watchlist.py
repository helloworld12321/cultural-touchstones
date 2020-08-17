"""
This file tests the endpoints in the "watchlist" blueprint.
"""

from http import HTTPStatus

from cultural_touchstones.db import MAX_WATCHLIST_ITEM_LENGTH

def test_GET_watchlist_returns_an_empty_list_when_the_database_is_empty(empty_client):
    response = empty_client.get('/watchlist')
    assert response.status_code == HTTPStatus.OK
    assert response.json == []

def test_GET_watchlist_returns_a_list_of_the_contents_of_the_watchlist_items(client_with_data):
    client, data = client_with_data
    expected_json = [
        item.contents
        for item in sorted(data, key=lambda item: item.position)
    ]
    response = client.get('/watchlist')
    assert response.status_code == HTTPStatus.OK
    assert response.json == expected_json

def test_PUT_watchlist_creates_watchlist_items_in_the_right_order_that_can_be_read_later(empty_client):
    movie_names = [
        'A Fistful of Dollars',
        'For a Few Dollars More',
        'The Good, The Bad, and the Ugly',
    ]
    put_response = empty_client.put('/watchlist', json=movie_names)
    assert put_response.status_code == HTTPStatus.NO_CONTENT
    get_response = empty_client.get('/watchlist')
    assert get_response.status_code == HTTPStatus.OK
    assert get_response.json == movie_names


def test_PUT_watchlist_overwrites_any_existing_watchlist(client_with_data):
    movie_names = [
        'A Fistful of Dollars',
        'For a Few Dollars More',
        'The Good, The Bad, and the Ugly',
    ]
    client, _ = client_with_data
    put_response = client.put('/watchlist', json=movie_names)
    assert put_response.status_code == HTTPStatus.NO_CONTENT
    get_response = client.get('/watchlist')
    assert get_response.status_code == HTTPStatus.OK
    assert get_response.json == movie_names

def test_PUT_watchlist_accepts_an_empty_watchlist(client_with_data):
    client, _ = client_with_data
    put_response = client.put('/watchlist', json=[])
    assert put_response.status_code == HTTPStatus.NO_CONTENT
    get_response = client.get('/watchlist')
    assert get_response.status_code == HTTPStatus.OK
    assert get_response.json == []

def test_PUT_watchlist_handles_unicode_just_fine(empty_client):
    movie_names = [
        'ä',
        'ä' * MAX_WATCHLIST_ITEM_LENGTH,
        # Test the Santa emoji, since it's an astral-plane character.
        '🎅' * MAX_WATCHLIST_ITEM_LENGTH,
    ]
    put_response = empty_client.put('/watchlist', json=movie_names)
    assert put_response.status_code == HTTPStatus.NO_CONTENT
    get_response = empty_client.get('/watchlist')
    assert get_response.status_code == HTTPStatus.OK
    assert get_response.json == movie_names

def test_PUT_watchlist_fails_if_one_of_the_movie_names_is_too_long(empty_client):
    response1 = empty_client.put('/watchlist', json=[
        '.' * MAX_WATCHLIST_ITEM_LENGTH,
    ])
    assert response1.status_code == HTTPStatus.NO_CONTENT
    response2 = empty_client.put('/watchlist', json=[
        '.' * (MAX_WATCHLIST_ITEM_LENGTH + 5),
    ])
    assert response2.status_code == HTTPStatus.BAD_REQUEST

def test_PUT_watchlist_fails_if_the_payload_is_not_a_list_of_strings(empty_client):
    response1 = empty_client.put('/watchlist', json=[1, 2, 3])
    assert response1.status_code == HTTPStatus.BAD_REQUEST
    response2 = empty_client.put('/watchlist', json={
        0: 'Better Luck Tomorrow',
        1: 'The Fast and the Furious',
        2: '2 Fast 2 Furious',
    })
    assert response2.status_code == HTTPStatus.BAD_REQUEST
