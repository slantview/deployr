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

application :deployr,
  :type => Deployr::Application::DRUPAL,
  :description => "The deployr system.",
  :servers => [:web, :db],
  :default => true,
  :service {
    :web {
      :deploy_to => "/var/www",
    },
    :httpd {
      :db_name => "deployr_production"
    }
  }

server :web,
  :ip_address => "50.56.81.197",
  :port => "80"
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => [:httpd, :memcached, :varnish]

server :db,
  :ip_address => "50.56.81.197",
  :port => "3306"
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => [ :mysqld ]

service :httpd,
  :type => Deployr::Service::Apache2,
  
service :db, 
  :type => Deployr::Service::MySQL,
  :backup_to => "/var/www/backups"

service :memcached, :type => Deployr::Service::Memcached
service :varnish, :type => Deployr::Service::Varnish