votes-in-parliament
===================

Who are you and what are you doing here?
----------------------------------------
I'm a little Sinatra application that totters off to http://data.openaustralia.org/ and shows you the divisions (votes) that happened in parliament that day.

My author was probably taking the "release early" thing a bit too far.

How do I run you?
---------------------------
Make sure you have the required gems:

    $ sudo gem install sinatra hpricot

Start me up:

    $ ruby main.rb

Then visit http://localhost:4567/2010-06-23/6 - which will show you the 6th division that happened on the 23rd of June, 2010 in the House of Representatives (no Senate support right now).

Inspriation
---------------
Inspired by the delightful ephemerality of Stephen Bartlett's [words-in-parliament](http://github.com/srbartlett/words-in-parliament).

License
-----------
Fork me, because I'm licensed under the [GNU AGPL v3](http://www.gnu.org/licenses/agpl-3.0.html).
