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
        :application_subdir => '',
        :current_dir => 'current',
        :releases_dir => 'releases',
        :shared_dir => 'shared',
        :shared_config_dir => 'settings',
        :shared_files_dir => 'files',
        :cached_dir => 'cached-copy',
        :copy_exclude => ['sites/default/settings.php', 'sites/default/files'],
        :code_dir => '',
        :site_dir => 'sites/default',
        :settings_file => 'settings.php',
        :drush => '/usr/bin/drush'

      ssh_key :default,
        :type => "rsa",
        :private_key => "~/.ssh/id_rsa",
        :public_key => "~/.ssh/id_rsa.pub"

      # Deploy hooks
      hook :check,
        :command => :deploy,
        :after => nil,
        :callback => "check"

      hook :build,
        :command => :deploy,
        :after => :check,
        :callback => "build"

      hook :predeploy_test,
        :command => :deploy,
        :after => :build,
        :callback => "predeploy_test"

      hook :backup_database,
        :command => :deploy,
        :after => :predeploy_test,
        :callback => "backup_database"

      hook :deploy,
        :command => :deploy,
        :after => :backup_database,
        :callback => "deploy"

      hook :shared_files,
        :command => :deploy,
        :after => :deploy,
        :callback => "shared_files"

      hook :symlink,
        :command => :deploy,
        :after => :shared_files,
        :callback => "symlink"

      hook :clear_cache,
        :command => :deploy,
        :after => :symlink,
        :callback => "clear_cache"

      hook :restart_services,
        :command => :deploy,
        :after => :clear_cache,
        :callback => "restart_services"

      hook :postdeploy_test,
        :command => :deploy,
        :after => :restart_services,
        :callback => "postdeploy_test"

      # Rollback hooks
      hook :maintenance_mode_on,
        :command => :rollback,
        :after => nil,
        :callback => "maintenance_mode_on"

      hook :backup_database,
        :command => :rollback,
        :after => :maintenance_mode_on,
        :callback => "backup_database"

      hook :restore_database,
        :command => :rollback,
        :after => :backup_database,
        :callback => "restore_database"

      hook :rollback_code,
        :command => :rollback,
        :after => :restore_database,
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
        #:backup_command => lambda { Deployr::Service::MySQL.backup },
        :backup_to => "/var/www/backups"

      service :varnish,
        :start_command => "service varnish start",
        :stop_command => "service varnish stop",
        :restart_command => "service varnish restart"

      module Deploy
        def check
          ui.msg "Deploy#check"
          # Test dependencies / build tools
          #@strategy.check!
          #@source.check!
        end

        def build
          ui.msg "Deploy#build"
          # Build project using build tools
          #@source.build!
        end

        def predeploy_test
          ui.msg "Deploy#predeploy_test"
          # Test server connection
          @deployment.servers.each do |name, server|
            ui.info "Testing Server #{name} - #{server}"
            server.connect
            ui.info "#{name} OK."
          end
        end

        def backup_database
          # drush sql-dump --result-file=../18.sql    Save SQL dump to the directory above Drupal root.
          # drush sql-dump --skip-tables-key=common
          # PREVIOUS_RELEASE=`ls -tr /var/www/test.workhabit.com/releases | tail -1`; drush sql-dump --root=/var/www/test.workhabit.com/current --result-file=/var/www/test.workhabit.com/releases/${PREVIOUS_RELEASE}/backup_${PREVIOUS_RELEASE}.sql
          root_dir = File.join(@deployment.releases_path, "${PREVIOUS_RELEASE}", @deployment.code_dir)
          backup_file = File.join(@deployment.releases_path, "${PREVIOUS_RELEASE}", "backup_${CURRENT_DATETIME}.sql")

          cmd = [
            "PREVIOUS_RELEASE=`ls -tr #{@deployment.releases_path} | tail -1`;",
            "CURRENT_DATETIME=`date +%Y%m%d%H%M%S`;",
            "drush",
            "sql-dump",
            "--root=#{root_dir}",
            "--result-file=#{backup_file}",
            "--gzip"
          ].join(' ')

          ui.msg "Running database backup to #{@deployment.releases_path}/${PREVIOUS_RELEASE}/backup_${CURRENT_DATETIME}.sql"
          output = @deployment.invoke_command(cmd)
          output.each do |server, text|
            if text !~ /success/
              ui.fatal text
              raise Deployr::CommandError, "Database backup not successful on #{server}."
            end
          end
        end

        def deploy
          ui.msg "Deploy#deploy"
          # Connect to server (if not connected)
          # Upload all/partial files to numbered directory
          @strategy.deploy!
        end

        def shared_files
          ui.msg "Deploy#shared_files"
          # Upload shared files (if necessary)
          # Relink settings.php
          # Relink files dir
          real_settings_file = File.join(@deployment.shared_path, @deployment.settings_file)
          settings_file_link = File.join(@deployment.release_path, @deployment.code_dir, @deployment.site_dir, @deployment.settings_file)
          @deployment.invoke_command("ln -s #{real_settings_file} #{settings_file_link}")

          real_files_dir = File.join(@deployment.shared_path, 'files')
          files_dir_link = File.join(File.join(@deployment.release_path, @deployment.code_dir, @deployment.site_dir), 'files')
          @deployment.invoke_command("ln -s #{real_files_dir} #{files_dir_link}")
        end

        def symlink
          ui.msg "Deploy#symlink"
          # Update current symlink to current version
          link_from = File.join(@deployment.release_path, @deployment.code_dir)
          link_to = @deployment.current_path
          @deployment.invoke_command("rm -f #{@deployment.current_path} && ln -s #{link_from} #{link_to}")
          # So we know what way to rollback, and we don't re-rollback.
          @deployment.pointer_moved = true
        end

        def clear_cache
          ui.msg "Deploy#clear_cache"
          @deployment.invoke_command("drush --root=#{@deployment.current_path} cache-clear all -y")
        end

        def restart_services
          ui.msg "Deploy#restart_services"
          # run service restarts based on services defined.
          # TODO: FIXME this should be up there ^^^
          @deployment.invoke_command("drush --root=#{@deployment.current_path} cache-clear all -y")
        end

        def postdeploy_test
          ui.msg "Deploy#postdeploy_test"
          # Run any post deploy tests including
          #   * performance
          #   * alive
          #   * load test
          #   * notification
        end

        def rollback(msg)
          # reset the current pointer
          ui.fatal "#{msg}" if msg
          ui.fatal "Rolling back."
          # Move pointer
          # remove deployment dir
          if @deployment.pointer_moved || !error
            cmd = [
              "PREVIOUS_RELEASE=`ls -tr #{@deployment.releases_path} | tail -1`;",
              "rm -f #{@deployment.current_path} && ln -s #{@deployment.releases_path}/${PREVIOUS_RELEASE} #{@deployment.current_path}"
            ].join(' ')

            @deployment.invoke_command(cmd)
          end
          ui.fatal "Rollback complete."
        end
      end

      module Rollback
        def maintenance_mode_on
          ui.msg "Turning on Maintenance mode"
          #@deployment.invoke("echo MAINTENANCE_MODE_COMMAND_HERE")
        end

        def backup_database
          ui.msg "Backing up current database"

          root_dir = File.join(@deployment.releases_path, "${CURRENT_RELEASE}", @deployment.code_dir)
          backup_file = File.join(@deployment.releases_path, "${CURRENT_RELEASE}", "backup_${CURRENT_DATETIME}.sql")

          cmd = [
            "CURRENT_RELEASE=`ls -tr #{@deployment.releases_path} | tail -1`;",
            "CURRENT_DATETIME=`date +%Y%m%d%H%M%S`;",
            "drush",
            "sql-dump",
            "--root=#{root_dir}",
            "--result-file=#{backup_file}",
            "--gzip"
          ].join(' ')

          ui.msg "Running database backup to #{@deployment.releases_path}/${CURRENT_RELEASE}/backup_${CURRENT_DATETIME}.sql"
          output = @deployment.invoke_command(cmd)
          output.each do |server, text|
            if text !~ /success/
              ui.fatal text
              raise Deployr::CommandError, "Database backup not successful on #{server}."
            end
          end
        end

        def restore_database
          ui.msg "Restoring previous database"

          root_dir = File.join(@deployment.releases_path, "${PREVIOUS_RELEASE}", @deployment.code_dir)

          cmd = [
            "PREVIOUS_RELEASE=`ls -tr #{@deployment.releases_path} | tail -2 | head -1`;",
            "PREVIOUS_DATABASE=`ls -tr #{@deployment.releases_path}/${PREVIOUS_RELEASE}/backup_*.sql.gz | tail -1",
            "gunzip ${PREVIOUS_DATABASE};",
            "CONNECT=`drush --root=#{root_dir} sql-connect`",
            "${CONNECT} < ${PREVIOUS_DATABASE"
          ].join(' ')

          ui.msg "Running database restore from previous database."
          #output = @deployment.invoke_command("echo #{cmd}")
          # output.each do |server, text|
          #   if text !~ /success/
          #     ui.fatal text
          #     raise Deployr::CommandError, "Database backup not successful on #{server}."
          #   end
          # end
        end

        def rollback(msg = '')
          ui.msg "Rolling back."

          # Move pointer to maintenance page
          # Backup database on currently deployed code base.
          # Restore previous database
          # Restore pointer to previous code

          ui.msg "Rollback complete."
        end

        def rollback_code
          cmd = [
            "PREVIOUS_RELEASE=`ls -tr #{@deployment.releases_path} | tail -2 | head -1`;",
            "rm -f #{@deployment.current_path} && ln -s #{@deployment.releases_path}/${PREVIOUS_RELEASE} #{@deployment.current_path}"
          ].join(' ')

          @deployment.invoke_command(cmd)
        end
      end
    end
  end
end
