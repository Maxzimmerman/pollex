ExUnit.start()

# Start the application (without Repo supervised)
{:ok, _} = Application.ensure_all_started(:pollex)

# Explicitly start the Repo (so it’s shared across all tests)
{:ok, _pid} = Pollex.Repo.start_link()

# Use manual mode for transactional tests
Ecto.Adapters.SQL.Sandbox.mode(Pollex.Repo, :manual)
