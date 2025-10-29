defmodule Pollex.NebulexLocalCache do
  use Nebulex.Cache,
    otp_app: :pollex,
    adapter: Nebulex.Adapters.Local
end
