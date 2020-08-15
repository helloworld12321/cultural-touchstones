import setuptools

setuptools.setup(
    name="cultural-touchstones",
    version="0.0.0",
    author="Joe Moonan Walbran",
    author_email="walbr037@morris.umn.edu",
    description=
        "A web app to keep track of movies you've been meaning to watch.",
    url="https://github.com/helloworld12321/cultural-touchstones",
    packages=setuptools.find_packages(),
    zip_safe=False,
    install_requires=[
        'flask',
        'mariadb',
    ],
    setup_requires=[
        'pytest-runner',
    ],
    tests_require=[
        'pytest',
    ],
    python_requires='>=3.6',
)
