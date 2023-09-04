require_relative '../../lib/init'
require_relative '../../lib/configuration/management/framework/helpers/file_system'
require_relative '../../lib/configuration/management/framework/helpers/apt'
require_relative '../../lib/configuration/management/framework/helpers/systemd'

module Configuration
  module Management
    module Framework
      class LepStack

        INDEX_FILE = <<-PHP
<?php
header("Content-Type: text/plain");
echo "Hello, world!\\n";
?>
PHP

        NGINX_CONF = <<-CONF
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    server_name _;
    root /var/www/html/default/public_html;
    index index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \\.php$ {
        fastcgi_pass unix:/var/run/php/php7.2-fpm.sock;
        include snippets/fastcgi-php.conf;
    }

    location ~ /\\.ht {
        deny all;
    }
}
CONF

        attr_reader :hosts
        def initialize
          @hosts = {
            'password': '-',
            '1.1.1.1': {
              'user': 'root'
            },
            '2.2.2.2': {
              'user': 'root'
            }
          }
        end

        def execute
          AptHelper.install_packages 'nginx', 'php-fpm'
          FileSystemHelper.create_file '/etc/nginx/sites-enabled', 'default'
          FileSystemHelper.update_content '/etc/nginx/sites-enabled/default', NGINX_CONF
          FileSystemHelper.create_file '/var/www/html/default/public_html', 'index.php', :ownership => 'www-data:www-data', :permission => 644
          FileSystemHelper.change_owner '/var/www/html/*', 'www-data:www-data', '-R'
          FileSystemHelper.update_content '/var/www/html/default/public_html/index.php', INDEX_FILE
          SystemdHelper.restart_service 'nginx'
          SystemdHelper.restart_service 'php7.2-fpm'
          SystemdHelper.enable_service 'nginx'
          SystemdHelper.enable_service 'php7.2-fpm'
        end
      end
    end
  end
end
