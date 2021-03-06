module BME
  class IFindHelpersForRequest
    def initialize requests_helper
      @requests_helper = requests_helper
    end

    def start request
      Thread.new{find_helpers_for_request request}
    end

    def find_helpers_for_request request
      40.times do
        TheLogger.log.info "thread finding helpers for request #{request}"
        request.reload
       if request.stopped || request.answered
         Thread.exit
       end
        @requests_helper.check_request request, 1
        TheLogger.log.info "finished finding helpers"
        sleep 4 # seconds
      end
    end
  end
end
