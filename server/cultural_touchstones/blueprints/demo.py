"""
This file contains some temporary routes for use during development.

It's like a scratchpad for experimenting.
"""

from flask import Blueprint, json

from .. import db

bp = Blueprint('demo', __name__, url_prefix='/demo')

# Here's a simple page that says hello.
@bp.route('/hello')
def hello():
    return 'Hello, World!'

@bp.route('/watchlist-items')
def watchlist_items():
    db_cursor = db.get_connection().cursor()
    db_cursor.execute('SELECT * FROM watchlist_items')
    return json.jsonify(db_cursor.fetchall())
