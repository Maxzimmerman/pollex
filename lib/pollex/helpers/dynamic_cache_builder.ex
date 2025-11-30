defmodule Pollex.DynamicCacheBuilder do
  @moduledoc false

  # Builds a unique Nebulex local cache module for the given atom (e.g. :a)
  def build(letter) when is_atom(letter) do
    name = Atom.to_string(letter) |> String.upcase()
    module = Module.concat([Pollex.DynamicCache, name])

    case Code.ensure_loaded(module) do
      {:module, _} ->
        module

      _ ->
        create_cache(module)
    end
  end

  defp create_cache(module) do
    {:module, module, _, _} =
      defmodule module do
        use Nebulex.Cache,
          otp_app: :pollex,
          adapter: Nebulex.Adapters.Local
      end

    module
  end
end
