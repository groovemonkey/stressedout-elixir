defmodule Stressedout.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stressedout.Users` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        address: "some address",
        id: "7488a646-e31f-11e4-aace-600308960662",
        name: "some name"
      })
      |> Stressedout.Users.create_user()

    user
  end
end
