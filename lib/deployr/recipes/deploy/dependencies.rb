require 'deployr/recipes/deploy/local_dependency'
require 'deployr/recipes/deploy/remote_dependency'

module Deployr
  module Deploy
    class Dependencies
      include Enumerable

      attr_reader :deployment

      def initialize(deployment)
        @deployment = deployment
        @dependencies = []
        yield self if block_given?
      end

      def check
        yield self
        self
      end

      def remote
        dep = RemoteDependency.new(deployment)
        @dependencies << dep
        dep
      end

      def local
        dep = LocalDependency.new(deployment)
        @dependencies << dep
        dep
      end

      def each
        @dependencies.each { |d| yield d }
        self
      end

      def pass?
        all? { |d| d.pass? }
      end
    end
  end
end
