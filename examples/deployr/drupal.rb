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
  :ip_address => "50.56.81.197",
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => ["httpd", "mysqld", "memcached", "varnish"]

server "testing",
  :ip_address => "50.56.81.197",
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => ["httpd", "mysqld", "memcached", "varnish"]

server "web",
  :ip_address => "50.56.81.197",
  :ssh_user => "root",
  :ssh_key => "default",
  :ssh_password => "password",
  :services => ["httpd", "memcached", "varnish"]

server "db",
  :ip_address => "50.56.81.197",
  :ssh_user => "root",
  :ssh_key => "default",
  :ssh_password => "password",
  :services => ["mysqld"]

service "httpd",
  :type => :service_apache2,
  :port => "80",
  :start_command => "service apache2 start",
  :stop_command => "service apache2 stop",
  :restart_command => "service apache2 restart",
  :deploy_to => "/var/www",
  :backup_command => nil,
  :backup_to => "/var/www/backups"


