module Fluent

class RiakOutput < BufferedOutput

  def initialize
    super
  end
  def configure(conf)
  end
  def start
  end
  def shutdown
    super
  end
  def format(tag, time, record)
  end
  def emit(tag, es, chain)
  end
  def write(chunk)
  end

end
