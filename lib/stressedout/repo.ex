defmodule Stressedout.Repo do
  use Ecto.Repo,
    otp_app: :stressedout,
    adapter: Ecto.Adapters.Postgres
end
