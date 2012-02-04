#
# Author:: Steve Rude (<steve@slantview.com>)
# Copyright:: Copyright (c) 2012 Slantview Media.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

application "deployr",
  :type => :application_drupal,
  :description => "The deployr system.",
  :environments => ["production", "testing", "development"]

environment "production",
  :description => "The production environment",
  :servers => ["web", "db"]

environment "testing",
  :description => "The testing environment",
  :servers => ["testing"]

environment "development",
  :description => "The development environment",
  :servers => ["development"]

server "development",
  :type => :chef_client,
  :chef_server => "http://chef.deployr.com:4000",
  :chef_role => "development",
  :chef_environment => "development",
  :services => ["httpd", "mysqld", "memcached", "varnish"],
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password"

server "testing",
  :type => :chef_client,
  :chef_server => "http://chef.deployr.com:4000",
  :chef_role => "web",
  :chef_environment => "testing",
  :services => ["httpd", "mysqld", "memcached", "varnish"],
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password"

server "web",
  :type => :chef_client,
  :chef_server => "http://chef.deployr.com:4000",
  :chef_role => "web",
  :chef_environment => "production",
  :services => ["httpd", "memcached", "varnish"],
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password"

server "db",
  :type => :chef_client,
  :chef_server => "http://chef.deployr.com:4000",
  :chef_role => "web",
  :chef_environment => "production",
  :services => ["mysqld"],
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password"

service "httpd",
  :type => :service_apache2,
  :port => "80",
  :start_command => "service apache2 start",
  :stop_command => "service apache2 stop",
  :restart_command => "service apache2 restart",
  :deploy_to => "/var/www",
  :backup_command => nil,
  :backup_to => "/var/www/backups"

service "mysqld",
  :type => :service_mysql,
  :port => "3306",
  :start_command => "service mysqld start",
  :stop_command => "service mysqld stop",
  :restart_command => "service mysqld restart",
  :backup_command => lambda { Deployr::Service::MySQL.backup },
  :backup_to => "/var/www/backups"

service "memcached",
  :type => :service_memcached,
  :start_command => "service memcached start",
  :stop_command => "service memcached stop",
  :restart_command => "service memcached restart"

service "varnish",
  :type => :service_varnish,
  :start_command => "service varnish start",
  :stop_command => "service varnish stop",
  :restart_command => "service varnish restart"

key "default",
  :type => "rsa",
  :private_key => "~/.ssh/id_rsa",
  :public_key => "~/.ssh/id_rsa.pub"

