# What is it good for?
Webfaction's email addresses' settings can be managed via the control panel.
  
But what if your email users want to modify their own settings, such as the auto-responder? You're not going to give them access to the control panel, right?

This Sinatra app addresses this issue by providing a small interface to edit the auto-responder settings.

The users can login via their IMAP credentials and can activate/deactivate the auto-responder and set its subject and message for an email address that they own.

# Installation on Webfaction
### Create a new application from the control panel

1. From the control panel, go to ***DOMAIN/WEBSITES***, then ***Applications***.
2. Give you application a name (will be later referred as `appname`)
3. Choose ***Passenger*** as app category and ***3.0.11*** as app type
4. Press Save
5. Create a Website by pointing one of your domain to the application

### Deploy the application
ssh into your webfaction server and go to the application folder:

```
$ cd webapps/appname
```

Create the GEM_HOME variable for installing Sinatra, put the bin folder on the PATH and set the RUBYLIB variable:

```
$ export GEM_HOME=$PWD/gems
$ export PATH=$PWD/bin:$PATH
$ export RUBYLIB=$PWD/lib
```

Install Sinatra and Bundle:

```
$ gem install sinatra
$ gem install bundle
```

Delete the default hello_world project:
 
```
$ rm -rf hello_world/
```

Clone the webfaction_autoresponder project:

```
$ git clone https://github.com/etnlmy/webfaction_autoresponder.git 
```

Point nginx to your new app by editing the `root` line in `~/webapps/appname/nginx/conf/nginx.conf` as follows:

```
/home/username/webapps/appname/hello_world/public;
```

becomes

```
/home/username/webapps/appname/webfaction_autoresponder/public;
```

### Install the dependencies with Bundle

```
$ cd webfaction_autoresponder
$ bundle install
```


### Configure the application

The application will need to connect to the Webfaction API (see [API reference](http://docs.webfaction.com/xmlrpc-api/)) and therefore you will need to provide your Webfaction credentials in a configuration file.

Create a new file `config/secrets.yml`:
 
```
$ mkdir config && cd config
$ touch secrets.yml
```
and fill in your credentials like this:

```
webfaction_user: "username"
webfaction_password: "password"
```
You can now restart nginx by simply typing `restart` and visit your page.
