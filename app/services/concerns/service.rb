# Class methods are resistant to change, and while a service's intention reads
# better when using the convenience of a class method, wrapping the
# initialization of an instance gives us greater freedom for future change.
#
# This concern provides for calling a service as if the receiver were a class
# method, while internally it simply instantiates a new instance with the
# passed arguments.
#
module Service
  extend ActiveSupport::Concern

  included do
    def self.call(*args)
      new(*args).call
    end
  end
end
