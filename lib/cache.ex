defmodule Cache do
  use CacheAdapter

  def start_link(opts) do
    IO.puts "Called start link"
    name = Keyword.fetch!(opts, :name)
    GenServer.start_link(__MODULE__, opts, name: name)
  end

  def init(init_arg) do
    IO.puts "Called init"
    IO.inspect(init_arg)

    lookup("domain", "prefix")
    refresh("domain")
    {:ok, %{}}
  end

  @impl true
  def lookup(domain, prefix) do
    IO.puts("Called lookup")
    IO.puts(domain)
    IO.puts(prefix)
  end

  @impl true
  def refresh(domain) do
    IO.puts("Called refresh")
    IO.puts(domain)
  end
end
