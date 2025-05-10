# frozen_string_literal: true

module Overnight
  class Nightscout
    # constants that are shared between multiple Nightscout classes
    module Constants
      # the interval between updates from Loop to Nightscout
      LOOP_INTERVAL = 300.0
    end
  end
end
