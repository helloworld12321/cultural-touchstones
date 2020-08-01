import os
from flask import Flask

def create_app(test_config=None):
    # create and configure the app
    app = Flask(__name__, instance_relative_config=True)

    if test_config is None:
        # Load the instance config, if it exists, when not testing.
        app.config.from_envvar("CULTURAL_TOUCHSTONES_SETTINGS", silent=False)
    else:
        # Load the test config if one was passed in.
        app.config.from_mapping(test_config)

    # Ensure the instance folder exists.
    try:
        os.makedirs(app.instance_path)
    except OSError:
        pass

    # Here's a simple page that says hello.
    @app.route('/hello')
    def hello():
        return 'Hello, World!'

    return app

