defmodule Stressedout.ProductsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stressedout.Products` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        description: "some description",
        id: "7488a646-e31f-11e4-aace-600308960662",
        name: "some name",
        price: 120.5
      })
      |> Stressedout.Products.create_product()

    product
  end
end
