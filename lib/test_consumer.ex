defmodule TestConsumer do

  def init do
    Cache.start_link(name: :first)
  end
end
