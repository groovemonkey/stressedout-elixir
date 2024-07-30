defmodule StressedoutWeb.ReviewJSON do
  alias Stressedout.Reviews.Review

  @doc """
  Renders a list of reviews.
  """
  def index(%{reviews: reviews}) do
    %{data: for(review <- reviews, do: data(review))}
  end

  @doc """
  Renders a single review.
  """
  def show(%{review: review}) do
    %{data: data(review)}
  end

  defp data(%Review{} = review) do
    %{
      id: review.id,
      id: review.id,
      product_id: review.product_id,
      user_id: review.user_id,
      rating: review.rating,
      content: review.content
    }
  end
end
