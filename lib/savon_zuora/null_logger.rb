require "savon_zuora/logger"

module SavonZuora
  class NullLogger < Logger

    def log(*)
    end

  end
end
