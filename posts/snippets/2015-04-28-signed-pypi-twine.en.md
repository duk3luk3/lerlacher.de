---
title: PyPI package signing and upload with twine
tags: python, gpg
---

###1) Install wheel and twine

    sudo pip install twine
    sudo pip install wheel

(Or use your distribution's packages)

###2) Make a setup.py and a .pypirc

Not covered here

###3) Remove old package and make a new distributable

    rm dist/*
    python setup.py sdist bdist_wheel

###4) Sign and upload

    twine upload -s dist/*
