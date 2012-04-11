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

module Deployr
  class Platform
    class Drupal < Platform
      platform :drupal,
        :transfer => :cached_copy,
        :application_subdir => 'app',
        :config_subdir => 'shared/conf',
        :shared_files_subdir => 'shared/files',
        :cached_dir => 'cached-copy'

      key :default,
        :type => "rsa",
        :private_key => "~/.ssh/id_rsa",
        :public_key => "~/.ssh/id_rsa.pub"

      # Deploy hooks
      hook :check,
        :after => nil,
        :callback => "check"

      hook :build,
        :after => :check,
        :callback => "build"

      hook :predeploy_test,
        :after => :build,
        :callback => "predeploy_test"

      hook :deploy,
        :after => :predeploy_test,
        :callback => "deploy"

      hook :shared_files,
        :after => :deploy,
        :callback => "shared_files"

      hook :symlink,
        :after => :shared_files,
        :callback => "symlink"

      hook :postdeploy_test,
        :after => :symlink,
        :callback => "postdeploy_test"

      # Rollback hooks
      hook :rollback,
        :after => nil,
        :callback => "rollback"

      hook :rollback_code,
        :after => :rollback,
        :callback => "rollback_code"

      # Administrative hooks
      hook :cleanup,
        :after => nil,
        :callback => "cleanup"

      hook :web_enable,
        :after => nil,
        :callback => "web_enable"

      hook :web_disable,
        :after => nil,
        :callback => "web_disable"

      hook :clear_cache,
        :after => nil,
        :callback => "clear_cache"

      hook :download_db,
        :after => nil,
        :callback => "download_db"

      service :apache2,
        :deploy_to => "/var/www",
        :start_command => "service apache2 start",
        :stop_command => "service apache2 stop",
        :restart_command => "service apache2 restart"

      service :memcached,
        :start_command => "service memcached start",
        :stop_command => "service memcached stop",
        :restart_command => "service memcached restart"

      service :mysqld,
        :db_user => "root",
        :db_pass => "password",
        :db_name => "drupal",
        :db_host => "localhost",
        :db_port => "3306",
        :start_command => "service mysqld start",
        :stop_command => "service mysqld stop",
        :restart_command => "service mysqld restart",
        :backup_command => lambda { Deployr::Service::MySQL.backup },
        :backup_to => "/var/www/backups"

      service :memcached,
        :start_command => "service memcached start",
        :stop_command => "service memcached stop",
        :restart_command => "service memcached restart"

      service :varnish,
        :start_command => "service varnish start",
        :stop_command => "service varnish stop",
        :restart_command => "service varnish restart"

    end
  end
end
