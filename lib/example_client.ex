defmodule ExampleClient do
  def say_hello() do
    cached = ReqPollerCache.get()

    IO.puts("Hello")
    IO.inspect(cached)
  end
end
