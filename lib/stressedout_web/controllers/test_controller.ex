defmodule StressedoutWeb.TestController do
  use StressedoutWeb, :controller
  import Logger

  alias Stressedout.Repo
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

    IO.puts(
      "Nice. Product: #{inspect(product)}\nSample review from #{length(testreviews)} reviews: #{inspect(Enum.at(testreviews, 0))}"
    )

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

  # TODO write

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

  # def get_reviews_for_product(product_id) do
  #   query = """
  #   		SELECT u.name as username, r.rating, r.content
  #   		FROM reviews r
  #   		JOIN users u ON r.user_id = u.id
  #   		WHERE r.product_id = ?
  #   """
  #
  #   Ecto.Adapters.SQL.query(Repo, query, [product_id])
  #    end
end
