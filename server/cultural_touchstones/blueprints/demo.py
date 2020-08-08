"""
This file contains some temporary routes for use during development.

It's like a scratchpad for experimenting.
"""

from flask import Blueprint

bp = Blueprint('demo', __name__)

# Here's a simple page that says hello.
@bp.route('/hello')
def hello():
    return 'Hello, World!'
