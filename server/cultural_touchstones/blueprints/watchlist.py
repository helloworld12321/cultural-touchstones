"""
This blueprint provides endpoints for working with watchlists.
"""

from flask import Blueprint, json

from .. import db, utils

bp = Blueprint('watchlist', __name__)

@bp.route('/watchlist')
def watchlist():
    db_cursor = db.get_connection().cursor()
    db_cursor.execute(
        """
        SELECT contents FROM watchlist_items
            ORDER BY position
        """,
    )
    watchlist_items = list(utils.flatten(db_cursor.fetchall()))
    return json.jsonify(watchlist_items)
