#!/usr/bin/env python3

"""
This file manages running, testing, and linting the project.

Incidentally, we're not actually using setuptools to *package* anything--
Cultural Touchstones is distributed through git. setuptools' role in this
project is just to run commands. 🙃
"""

import setuptools

import distutils.errors
import distutils.log
import subprocess

class PytestFailedError(distutils.errors.DistutilsError):
    def __init__(self, pytest_exit_code):
        message = (
            f'Pytest failed with exit code {pytest_exit_code} '
            f'({pytest_exit_code.name})'
        )
        super().__init__(message)
        self.exit_code = pytest_exit_code

# Adapted from
# https://jichu4n.com/posts/how-to-add-custom-build-steps-and-commands-to-setuppy/
class PylintCommand(setuptools.Command):
    description = 'Run pylint.'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import pylint.lint
        pylint.lint.Run([
            '--load-plugins=pylint_quotes',
            'cultural-touchstones',
            'test/**',
            'setup.py',
        ])

class PytestCommand(setuptools.Command):
    description = 'Run pytest.'
    user_options = []

    def initialize_options(self):
        pass

    def finalize_options(self):
        pass

    def run(self):
        import pytest
        exit_code = pytest.main()
        if exit_code != pytest.ExitCode.OK:
            raise PytestFailedError(exit_code)

class GunicornCommand(setuptools.Command):
    description = 'Run Cultural Touchstones on the Gunicorn server.'
    user_options = [
        (
            'production',
            None,
            'Run in a production environment (for example, as a daemon).',
        )
    ]

    def initialize_options(self):
        # pylint: disable=attribute-defined-outside-init
        self.production = None

    def finalize_options(self):
        # pylint: disable=attribute-defined-outside-init
        self.production = bool(self.production)

    def run(self):
        # We could run Gunicorn through its Python API
        # (See https://docs.gunicorn.org/en/latest/custom.html)
        # But to do that, we would have to import the cultural_touchstones
        # package into its own setuptools, which would be pretty messy.
        if self.production:
            extra_gunicorn_arguments = ['--daemon']
        else:
            extra_gunicorn_arguments = []
        command = [
            'gunicorn',
            'cultural_touchstones:create_app()',
            *extra_gunicorn_arguments,
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
        "A web app to keep track of movies you've been meaning to watch.",
    url='https://github.com/helloworld12321/cultural-touchstones',
    packages=setuptools.find_packages(),
    cmdclass={
        'gunicorn': GunicornCommand,
        'pylint': PylintCommand,
        'pytest': PytestCommand,
    },
    python_requires='>=3.6',
)
