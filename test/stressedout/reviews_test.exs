defmodule Stressedout.ReviewsTest do
  use Stressedout.DataCase

  alias Stressedout.Reviews

  describe "reviews" do
    alias Stressedout.Reviews.Review

    import Stressedout.ReviewsFixtures

    @invalid_attrs %{id: nil, product_id: nil, user_id: nil, rating: nil, content: nil}

    test "list_reviews/0 returns all reviews" do
      review = review_fixture()
      assert Reviews.list_reviews() == [review]
    end

    test "get_review!/1 returns the review with given id" do
      review = review_fixture()
      assert Reviews.get_review!(review.id) == review
    end

    test "create_review/1 with valid data creates a review" do
      valid_attrs = %{
        id: "7488a646-e31f-11e4-aace-600308960662",
        product_id: "7488a646-e31f-11e4-aace-600308960662",
        user_id: "7488a646-e31f-11e4-aace-600308960662",
        rating: 42,
        content: "some content"
      }

      assert {:ok, %Review{} = review} = Reviews.create_review(valid_attrs)
      assert review.id == "7488a646-e31f-11e4-aace-600308960662"
      assert review.product_id == "7488a646-e31f-11e4-aace-600308960662"
      assert review.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert review.rating == 42
      assert review.content == "some content"
    end

    test "create_review/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Reviews.create_review(@invalid_attrs)
    end

    test "update_review/2 with valid data updates the review" do
      review = review_fixture()

      update_attrs = %{
        id: "7488a646-e31f-11e4-aace-600308960668",
        product_id: "7488a646-e31f-11e4-aace-600308960668",
        user_id: "7488a646-e31f-11e4-aace-600308960668",
        rating: 43,
        content: "some updated content"
      }

      assert {:ok, %Review{} = review} = Reviews.update_review(review, update_attrs)
      assert review.id == "7488a646-e31f-11e4-aace-600308960668"
      assert review.product_id == "7488a646-e31f-11e4-aace-600308960668"
      assert review.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert review.rating == 43
      assert review.content == "some updated content"
    end

    test "update_review/2 with invalid data returns error changeset" do
      review = review_fixture()
      assert {:error, %Ecto.Changeset{}} = Reviews.update_review(review, @invalid_attrs)
      assert review == Reviews.get_review!(review.id)
    end

    test "delete_review/1 deletes the review" do
      review = review_fixture()
      assert {:ok, %Review{}} = Reviews.delete_review(review)
      assert_raise Ecto.NoResultsError, fn -> Reviews.get_review!(review.id) end
    end

    test "change_review/1 returns a review changeset" do
      review = review_fixture()
      assert %Ecto.Changeset{} = Reviews.change_review(review)
    end
  end
end
