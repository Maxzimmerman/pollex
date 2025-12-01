defmodule Pollex.Helpers.DynamicCache do
  @moduledoc false

  # Creates a new Nebulex cache module dynamically at runtime.
  def build_local_cache(name, opts) do
    mod =
      Module.concat([Pollex, DynamicCache, name])

    # Build quoted code for a Nebulex local cache
    code =
      quote do
        use Nebulex.Cache,
          otp_app: :pollex,
          adapter: Nebulex.Adapters.Local

        @dynamic_config unquote(opts)

        def config() do
          @dynamic_config
        end
      end

    # Create & compile the module on the fly
    {:module, _module, _binary, _exports} = Module.create(mod, code, Macro.Env.location(__ENV__))

    mod
  end
end
