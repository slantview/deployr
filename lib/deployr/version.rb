module Deployr
  # We're doing this because we might write tests that deal
  # with other versions of bundler and we are unsure how to
  # handle this better. Borrowed from Bundler::Version.
  VERSION = '0.1.0' unless defined?(::Deployr::VERSION)
end