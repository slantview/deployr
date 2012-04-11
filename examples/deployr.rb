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
  :type => :drupal,
  :description => "The deployr system.",
  :default => true

server :web,
  :ip_address => "50.56.81.197",
  :port => "80"
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => [:apache2, :memcached, :varnish]

server :db,
  :ip_address => "50.56.81.197",
  :port => "3306"
  :ssh_user => "root",
  :ssh_key => "~/.ssh/id_rsa.pub",
  :ssh_password => "password",
  :services => [ :mysqld ]

