"""
This file contains functions for working with the database.
"""

from flask import current_app, g

import mariadb

MAX_WATCHLIST_ITEM_LENGTH = 300

def get_connection():
    """
    Return a connection to the database and cache it on the `g` object.

    Generally speaking, each app context has its own connection to the
    database; these are destroyed when the app context goes away (ie, when the
    server is done handling that request).
    """
    if 'db_connection' not in g:
        # mariadb.connect might throw an error if it can't connect to the
        # database, but that's okay--Flask will just turn that into an HTTP
        # 500 response, which is the correct behavior in this case.
        g.db_connection = mariadb.connect(
            user=current_app.config['DB_USER'],
            password=current_app.config['DB_PASSWORD'],
            host=current_app.config['DB_HOST'],
            port=current_app.config['DB_PORT'],
            database=current_app.config['DB_NAME'],
        )
    return g.db_connection

def close_connection():
    """
    Close the connection to the database (if one exists).

    This function should be called when tearing down the app context.
    """
    if 'db_connection' in g:
        g.db_connection.close()
        g.pop('db_connection')
