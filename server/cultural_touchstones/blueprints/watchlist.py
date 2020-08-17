"""
This blueprint provides endpoints for working with watchlists.
"""

from http import HTTPStatus

from flask import Blueprint, abort, json, request
from flask.views import MethodView

from .. import db, utils, validation

bp = Blueprint('watchlist', __name__)

class WatchlistApi(MethodView):
    """
    This class handles the /watchlist endpoint and its various verbs.
    """

    def get(self):
        """
        Return all the items in the watchlist, as a JSON array of strings.
        """
        db_cursor = db.get_connection().cursor()
        db_cursor.execute(
            """
            SELECT contents FROM watchlist_items
                ORDER BY position
            """,
        )
        watchlist_items = list(utils.flatten(db_cursor.fetchall()))
        return json.jsonify(watchlist_items)

    def put(self):
        """
        Replace all the items in the watchlist with a new list of items.

        The request body should be the new watchlist, as a JSON array of
        strings. We'll remember the order of items in this array.
        """
        # get_json() throws a BadRequest if the payload can't be parsed as JSON
        # (which is the desired behavior.)
        items = request.get_json()
        if not validation.is_list_of_strings(items):
            abort(
                HTTPStatus.BAD_REQUEST,
                'Request body should be a list of strings.',
            )
        for item in items:
            if not validation.is_short_enough(item):
                abort(
                    HTTPStatus.BAD_REQUEST,
                    (
                        f'{item!r} is too long; it should be to be at most '
                        f'{validation.MAX_WATCHLIST_ITEM_LENGTH} characters.'
                    )
                )
        db_cursor = db.get_connection().cursor()
        db_cursor.execute('START TRANSACTION')
        db_cursor.execute('DELETE FROM watchlist_items')
        # MariaDB Connector/Python is picky about executemany; you can't use
        # it with an empty list. So, we'll only run executemany if the list
        # has items in it.
        if items:
            db_cursor.executemany(
                """
                INSERT INTO watchlist_items (position, contents)
                    VALUES (?, ?)
                """,
                list(enumerate(items))
            )
        db_cursor.execute('COMMIT')
        return '', HTTPStatus.NO_CONTENT

bp.add_url_rule('/watchlist', view_func=WatchlistApi.as_view('watchlist'))
