# Annotations display app

This app is a modified version of the app used by Vox Media to display annotations.

## Prereqs
 - Ruby 2.2.5
 - Bundler

The best way to get setup is to use a ruby manager such as rvm, rbenv, or chruby. You may also be able to install a new ruby via your package manager.

On Mac OS X:

    brew install ruby-build rbenv
Brew will show some instructions to finish rbenv setup. Please follow them. Once you finish that start a new terminal session. From there run:

    rbenv install 2.2.5
    rbenv global 2.2.5

And start a new terminal session.

Install bundler
   gem install bundler


## App installation

Clone this app to your computer.

    git clone git@github.com:kavyasukumar/annotations-app.git

Make sure you have ruby 2.2.5 running on your machine

You must next setup your development environment to use [Google Middleman Drive](https://github.com/voxmedia/middleman-google_drive) gem. Follow the steps [here](http://tarbell.readthedocs.io/en/latest/install.html#configure-google-spreadsheet-access-optional).


Next you need to install the bundle...

    bundle install

And run the app

    bundle exec middleman

Your app should now be running on [http://localhost:4567](http://localhost:4567)
