#!/usr/bin/env python3

"""
This file manages installing, running, testing, and linting the project.

Incidentally, we're not actually using setuptools to *package* anything--
Cultural Touchstones is distributed through git. setuptools' role in this
project is just to manage dependencies and run commands. 🙃
"""

import setuptools

import distutils.cmd
import distutils.log
import subprocess

# Adapted from
# https://jichu4n.com/posts/how-to-add-custom-build-steps-and-commands-to-setuppy/
class PylintCommand(distutils.cmd.Command):
    """
    Run pylint.
    """

    description = 'run pylint'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import pylint.lint
        pylint.lint.Run([
            '--load-plugins',
            'pylint_quotes',
            'cultural-touchstones',
            'test/**',
            'setup.py',
        ])

class GunicornCommand(distutils.cmd.Command):
    """
    Run Cultural Touchstones on the Gunicorn server.
    """

    description = 'Run Cultural Touchstones on the Gunicorn server.'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        # We could run Gunicorn through its Python API
        # (See https://docs.gunicorn.org/en/latest/custom.html)
        # But to do that, we would have to import the cultural_touchstones
        # package into its own setuptools, which would be pretty messy.
        command = [
            'gunicorn',
            'cultural_touchstones:create_app()'
        ]
        self.announce(
            f'Running command: {command}',
            level=distutils.log.INFO,
        )
        subprocess.check_call(command)

setuptools.setup(
    name='cultural-touchstones',
    version='0.0.0',
    author='Joe Moonan Walbran',
    author_email='walbr037@morris.umn.edu',
    description=
        'A web app to keep track of movies you\'ve been meaning to watch.',
    url='https://github.com/helloworld12321/cultural-touchstones',
    packages=setuptools.find_packages(),
    zip_safe=False,
    cmdclass={
        'pylint': PylintCommand,
        'gunicorn': GunicornCommand,
    },
    install_requires=[
        'flask',
        'mariadb',
        'gunicorn',
    ],
    setup_requires=[
        'pytest-runner',
        'pylint',
        'pylint-quotes',
    ],
    tests_require=[
        'pytest',
    ],
    python_requires='>=3.6',
)
