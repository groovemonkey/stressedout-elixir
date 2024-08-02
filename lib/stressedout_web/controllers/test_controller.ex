defmodule StressedoutWeb.TestController do
  use StressedoutWeb, :controller

  alias Stressedout.Repo
  require Logger

  # alias Stressedout.Products.Product
  # alias Stressedout.Products
  # alias Ecto.Adapters.SQL

  def static(conn, _params) do
    conn
    |> render("static.html")
  end

  def dynamic(conn, _params) do
    time = DateTime.utc_now()

    conn
    |> render("dynamic.html", time: time)
  end

  def read(conn, _params) do
    {:ok, product} = Stressedout.Products.get_random_product()
    testreviews = Stressedout.Reviews.get_reviews_for_product(product.id)

    with {:ok, product} <- Stressedout.Products.get_random_product(),
         {:ok, count} <- count_orders_for_product(product.id),
         {:ok, distinct_purchasers} <- Stressedout.Products.count_distinct_purchasers(product.id),
         reviews <- Stressedout.Reviews.get_reviews_for_product(product.id) do
      conn
      |> render("read.html",
        product: product,
        orders: count,
        distinct_purchasers: distinct_purchasers,
        reviews: reviews
      )
    else
      error ->
        Logger.error("Error in /read: #{inspect(error)}")

        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "An error occurred", details: inspect(error)})
    end
  end

  def write(conn, _params) do
    # get a random product
    with {:ok, product} <- Stressedout.Products.get_random_product(),
         {:ok, user} <- Stressedout.Users.get_random_user() do
      # create an order
      quantity = Enum.random(0..5)

      attrs = %{
        date: NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second),
        user_id: user.id,
        product_id: product.id,
        quantity: quantity,
        total_price: (quantity * product.price) |> Float.round(2)
      }

      {:ok, order} =
        %Stressedout.Orders.Order{}
        |> Stressedout.Orders.Order.changeset(attrs)
        |> Repo.insert()

      # create a review
      attrs = %{
        product_id: product.id,
        user_id: user.id,
        rating: Enum.random(1..100),
        content: Faker.Lorem.paragraph()
      }

      {:ok, review} =
        %Stressedout.Reviews.Review{}
        |> Stressedout.Reviews.Review.changeset(attrs)
        |> Repo.insert()

      render(conn, "write.html", product: product, user: user, order: order, review: review)
    end
  end

  def count_orders_for_product(product_id) do
    query = """
    SELECT COUNT(*) FROM orders
    WHERE product_id = $1
    """

    case Ecto.Adapters.SQL.query(Repo, query, [product_id]) do
      {:ok, %{rows: [[count]]}} ->
        {:ok, count}

      {:error, _reason} = error ->
        error
    end
  end
end
