module BME
  class IFindHelpersForRequest
    def initialize requests_helper
      @request_helper = requests_helper
    end

    def start request
      Thread.new{find_helpers_for_request request}
    end

    def find_helpers_for_request request
      10.times do
        @requests_helper.check_request request, 1
        sleep 4 # seconds
      end
    end
  end
end
