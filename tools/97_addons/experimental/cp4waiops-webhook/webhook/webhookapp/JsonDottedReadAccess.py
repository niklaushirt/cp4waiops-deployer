# -*- coding: ASCII -*-
#
# This software is covered by the MIT License.
#
# Copyright (c) 2017-2021 Carsten Grohmann <mail@carstengrohmann.de>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
# documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
# persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
# Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
# WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

try:
    # Python2
    from UserDict import UserDict
except:
    # Python3
    from collections import UserDict


class JsonDottedReadAccess(UserDict):
    """
    Extended dictionary implementation to simplify access nested elements
    by a single key. Nested items separated by a dot "." in the key.

    Elements of an embedded list can accessed by a digit string.

    Example:
    >>> d = {u'level1': {u'level2-a': None,
    ...                  u'level2-b': [{'level3-b': 1}],
    ...                  u'level2-c': {'level3-c': 1},
    ...                  u'level2-d': 'level3-d'}}
    >>> j = JsonDottedReadAccess(d)
    >>> j.get('level1')
    {u'level2-c': {'level3-c': 1}, u'level2-b': [{'level3-b': 1}], u'level2-a': None, u'level2-d': 'level3-d'}
    >>> j.get('level1.level2-d')
    'level3-d'
    >>> j.get('level1.level2-b')
    [{'level3-b': 1}]
    >>> j.get('level1.nonexisting')
    None
    >>> j['level1.nonexisting']
    Traceback (most recent call last):
      File "<stdin>", line 1, in <module>
      File "JsonDottedReadAccess.py", line 58, in __getitem__
        val = val[key]
    KeyError: 'nonexisting'
    """

    def __getitem__(self, key):
        keys = key.split('.')
        val = self.data
        for key in keys:
            if isinstance(val, list):
                if key.isdigit():
                    key = int(key)
                else:
                    raise KeyError('Use a numeric key instead of %s to access list elements.' % key)
            val = val[key]
        return val

    def get(self, key, failobj=None):
        try:
            return self.__getitem__(key)
        except (IndexError, KeyError):
            return failobj
