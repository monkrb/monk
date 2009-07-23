Monk
====

The glue framework for web development.

Description
-----------

Monk is a glue framework for web development. It means that instead of
installing all the tools you need for your projects, you can rely on a
git repository and a list of dependencies, and Monk takes care of the
rest. By default, it ships with a Sinatra application that includes
Contest, Stories, Webrat, Ohm and some other niceties, along with a
structure and helpful documentation to get your hands wet in no time.

But Monk also respects your tastes, and you are invited to create your
own versions of the skeleton app and your own list of dependencies. You
can add many different templates (different git repositories) and Monk
will help you manage them all.

Usage
-----

Install the monk gem and create your project:

    $ sudo gem install monk
    $ monk init myapp
    $ cd myapp
    $ rake

If the tests pass, it means that you can start hacking right away. If
they don't, just follow the instructions. As the default skeleton
is very opinionated, you will probably need to install and run
[Redis](http://code.google.com/p/redis/), a key-value database.

Check the `dependencies` file in the root of your project to see what
else is there. Monk works with git almost exclusively, but your project
can also depend on gems. Check the dependencies file to see what options
you have, and run the `dep` command line tool to verify it.

Installation
------------

    $ sudo gem install monk

License
-------

Copyright (c) 2009 Michel Martens and Damian Janowski

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
