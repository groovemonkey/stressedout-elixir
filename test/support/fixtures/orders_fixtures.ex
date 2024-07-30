defmodule Stressedout.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stressedout.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        date: ~U[2024-07-29 00:30:00Z],
        id: "7488a646-e31f-11e4-aace-600308960662",
        product_id: "7488a646-e31f-11e4-aace-600308960662",
        quantity: 42,
        total_price: 120.5,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Stressedout.Orders.create_order()

    order
  end
end
