git-daily
===========================

"git-daily on Ruby" is a tool which helps you to do daily workflow easier on Git. This is the Ruby version. 

The original PHP version is here: https://github.com/sotarok/git-daily

Sub-commands are::

    git daily init
    git daily config
    git daily push
    git daily pull
    git daily release open
    git daily release list
    git daily release sync
    git daily release close
    git daily hotfix  open
    git daily hotfix  list
    git daily hotfix  sync
    git daily hotfix  close
    git daily version
    git daily help


Requirements
--------------------------

* Git: >= 1.7.0
* Ruby: >= 1.8.3


Installation
--------------------------

Install from rubygems ::

    gem install git-daily

Install develop version ::

    cd /path/to/dir
    git clone git://github.com/koichiro/git-daily.git
    cd git-daily
    rake build
    gem install pkg/git-daily-X.X.X.gem

Cheat Sheet
--------------------------

Initialization
^^^^^^^^^^^^^^^^^^^^^^^^^^

To initialize, use ::

    git daily init


Configuration
^^^^^^^^^^^^^^^^^^^^^^^^^^

* To show configuration for git-daliy use ::

    git daily config

* To set the configuration use ::

    git daily config [<key>] [<value>]

Release
^^^^^^^^^^^^^^^^^^^^^^^^^^

* To open the release process of the day, use ::

    git daily release open

* To sync opened or closed daily release process, use ::

    git daily release sync

* To show the release list, use::

    git daily release list

* When gitdaily.logurl is defined, git-daily shows author lists
  with logurl. git-daily replaces %s in gitdaily.logurl to a commit id. ::

    [config]
    gitdaily.logurl = "http://github.com/user/git-daily/commit/%s"

    [output]
    @userA:
    http://github.com/user/git-daily/commit/0123456789.....
    ...

* To close daily release process, use ::

    git daily release close

Hotfix
^^^^^^^^^^^^^^^^^^^^^^^^^^

* To open the hotfix process of the day, use ::

    git daily hotfix open

* To sync opened or closed hotfix process, use ::

    git daily hotfix sync

* To show the release list, use::

    git daily hotfix list

* To close hotfix process, use ::

    git daily hotfix close


Contribution
-------------

Use `gitFlow <https://github.com/nvie/gitflow>`_ to develop git-daily.
When you want to fix some bugs or implemente some new features,
commit not to ``master`` branch but to ``develop`` branch.


Test
^^^^^^

    $ rake test


Links
-------

References here (Japanese Only).

* http://speakerdeck.com/u/sotarok/p/git-daily-a-tool-supports-a-daily-workflow-with-remote
* http://d.hatena.ne.jp/sotarok/20111015/pyfes_git_daily
