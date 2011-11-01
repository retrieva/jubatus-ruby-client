require 'msgpack/rpc'

module Jubatus
  class Classifier
    def initialize(hosts, name)
      raise ArgumentError, "hosts empty" if hosts.empty?

      @name = name
      @hosts = hosts
      @client = MessagePack::RPC::Client.new(*@hosts[rand(@hosts.size)])
    end

    def close
      @client.close
    end

    # RPC methods
    %w[save load set_config get_config train classify get_status].each do |method|
      self.class_eval <<-EOM
        def #{method}(*args)
          new_args = ["#{method}", @name.to_s] + args
          call(*new_args)
        end
      EOM
    end

    private

    def call(*argv)
      success, retval, error = @client.call(*argv)
      if success
        return retval
      else
        raise error
      end
    end
  end
end
