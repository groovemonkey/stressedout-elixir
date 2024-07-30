defmodule Stressedout.ReviewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Stressedout.Reviews` context.
  """

  @doc """
  Generate a review.
  """
  def review_fixture(attrs \\ %{}) do
    {:ok, review} =
      attrs
      |> Enum.into(%{
        content: "some content",
        id: "7488a646-e31f-11e4-aace-600308960662",
        product_id: "7488a646-e31f-11e4-aace-600308960662",
        rating: 42,
        user_id: "7488a646-e31f-11e4-aace-600308960662"
      })
      |> Stressedout.Reviews.create_review()

    review
  end
end
