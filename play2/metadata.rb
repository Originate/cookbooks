name             'play2'
maintainer       'Maxime Bury'
maintainer_email 'maxime.bury@originate.com'
license          'All rights reserved'
description      'Installs/Configures a Play2 application'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "java", "~> 1.14.0"
depends "artifact", "~> 1.10.3"