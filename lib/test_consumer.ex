defmodule TestConsumer do
  def init do
    EctoGenServerCache.start_link(name: :first)
  end
end
