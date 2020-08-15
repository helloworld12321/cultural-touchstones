"""
This is the entry point for the Flask server.
"""

import os

from flask import Flask

from . import db
from .blueprints import watchlist

# We'll use these environment variables to configure the server (if they're
# set.)
# The first entry in each tuple is the name of the environment variables; the
# second is a function to call on the value of the environment variable before
# putting it into Flask's configuration. (For example, you may want to convert
# the value to an int first.)
ENV_VARIABLES_TO_LOOK_AT = [
    ('DB_USER', str),
    ('DB_HOST', str),
    ('DB_PORT', int),
    ('DB_NAME', str),
    ('DB_PASSWORD', str),
]

DEFAULT_CONFIG = {
    'DB_USER': 'root',
    'DB_HOST': 'localhost',
    'DB_PORT': 3306,
    'DB_NAME': 'cultural_touchstones',
}

def create_app(test_config=None):
    """
    Create and configure the Flask app.
    """
    app = Flask(__name__, instance_relative_config=True)

    app.config.from_mapping(DEFAULT_CONFIG)
    if test_config is not None:
        # Load the test config if one was passed in.
        app.config.from_mapping(test_config)
    else:
        runtime_config = {
            name: convert(os.environ[name])
            for name, convert in ENV_VARIABLES_TO_LOOK_AT
            if name in os.environ
        }
        app.config.from_mapping(runtime_config)

    # Ensure the instance folder exists.
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    app.register_blueprint(watchlist.bp)

    # Make sure we clean up any resources after each request.
    app.teardown_appcontext(lambda _: db.close_connection())

    return app
