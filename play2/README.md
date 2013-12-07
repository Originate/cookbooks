# play2 cookbook

This cookbook is a working prototype allowing the deployment of applications written with 
the [Play framework](http://www.playframework.com/) on Amazon's [Opsworks](http://aws.amazon.com/opsworks/).

# Requirements

This cookbook depends on two other cookbooks:
- [java](http://community.opscode.com/cookbooks/java)
- [artifact](http://community.opscode.com/cookbooks/artifact)

Unfortunately, Opsworks doesn't know how to find these, so our approach is to use [Berkshelf]() to install all 
the dependencies into an app-specific repository, and use that as the custom cookbook repository in Opsworks.

Example:
```bash
git clone git://github.com/Originate/cookbooks.git originate-cookbooks
mkdir /tmp/cookbooks
# berks install will remove everything, including .git, from the target directory
berks install -b originate-cookbooks/play2/Berksfile -p /tmp/cookbooks
mv /tmp/cookbooks/* <custom-app-repo>
```

# Usage
1. Create a new Stack, add your `custom-app-repo` as the source of custom cookbooks
2. Create a new custom layer:
  - Add `play2::setup` to the setup lifecyle event recipes
  - Add `play2::deploy` to the deploy lifecyle event recipes
  - Start a new instance
3. Add your play application to the stack, and deploy it

Optionally:
- If your application is not at the root of your repository, you can add custom JSON to the stack to let
  this cookbook know:

  ```json
  {
    "deploy": {
      "<app-name>": {
        "scm": {
          "app_dir": "<path/to/app/in/repo>"
         }
      }
    }
  }
  ```
- If you want to customize some of the cookbook's attributes, you can add custom JSON to the stack:

  ```json
  {
    "play2": {
      "version": "2.1.3",
      "conf": {
        "application": {
          "langs": "en"
        },
        "logger": {
          "root": "ERROR",
          "play": "INFO",
          "application": "DEBUG"
        }
      }
    }
  }
  ```

That's it, you should be good to go.

# Attributes

## Framework installation
|Key|Type|Description|Default|
|---|----|-----------|-------|
|`version`|`String`|The Play version to install|`2.2.0`|
|`url`|`String`|Base url to download the play distribution|`http://downloads.typesafe.com/play`|

## Application command line options
|Key|Type|Description|Default|
|---|----|-----------|-------|
|`http_port`|`Integer`|`-Dhttp.port=...`|`nil`|
|`https_port`|`Integer`|`-Dhttps.port=...`|`nil`|
|`app_conf_file`|`String`|`-Dconfig.file=...`|`nil`|
|`log_conf_file`|`String`|`-Dlogger.file=...`|`nil`|
|`options`|`String`|Additional options that you'd like to pass to play on startup<br> (ie. `-Xms2048M -Xmx6144M ...`)|`nil`|
These options are only added if the attribute is defined.

## Application configuration
|Key|Type|Description|Default|
|---|----|-----------|-------|
|`conf`|`JSON`|A JSON reprensentation of `application.conf`|`nil`|

Enables specifying the entire application configuration from Opsworks JSON. This overwrites `conf/application.conf` 
if defined. A sample configuration can be seen in the `Vagrantfile`.
