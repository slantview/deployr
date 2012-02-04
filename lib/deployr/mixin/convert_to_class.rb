module Deployr
  class Mixin
    module ConvertToClassName
      extend self

      def convert_to_class_name(str)
        rname = nil
        regexp = %r{^(.+?)(_(.+))?$}
        
        mn = str.match(regexp)
        if mn
          rname = mn[1].capitalize

          while mn && mn[3]
            mn = mn[3].match(regexp)          
            rname << mn[1].capitalize if mn
          end
        end

        rname
      end
      
      def convert_to_snake_case(str, namespace=nil)
        str = str.dup
        str.sub!(/^#{namespace}(\:\:)?/, '') if namespace
        str.gsub!(/[A-Z]/) {|s| "_" + s}
        str.downcase!
        str.sub!(/^\_/, "")
        str
      end
      
      def snake_case_basename(str)
        with_namespace = convert_to_snake_case(str)
        with_namespace.split("::").last.sub(/^_/, '')
      end
      
      def filename_to_qualified_string(base, filename)
        file_base = File.basename(filename, ".rb")
        base.to_s + (file_base == 'default' ? '' : "_#{file_base}")
      end
      
    end
  end
end