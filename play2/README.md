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
```
git clone git://github.com/Originate/cookbooks.git originate-cookbooks
berks install -b originate-cookbooks/play2/Berksfile -p <custom-app-repo>
```

# Usage

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

These options are only added if the attribute is defined.

## Application configuration
|Key|Type|Description|Default|
|---|----|-----------|-------|
|`conf`|`JSON`|A JSON reprensentation of `application.conf`|`nil`|

Enables specifying the entire application configuration from Opsworks JSON. This overwrites `conf/application.conf` 
if defined. A sample configuration can be seen in the `Vagrantfile`.

# Author

Author:: Maxime Bury (<maxime.bury@originate.com>)
