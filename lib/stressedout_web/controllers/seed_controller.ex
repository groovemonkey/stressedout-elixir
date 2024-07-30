defmodule StressedoutWeb.SeedController do
  use StressedoutWeb, :controller
  alias Stressedout.Repo
  alias Stressedout.Users.User
  alias Stressedout.Products.Product
  alias Stressedout.Orders.Order
  alias Stressedout.Reviews.Review

  def firstrun(conn, _params) do
    # It's not really necessary to manually seed this app in a controller, since Phoenix has migrations
    conn
    |> put_status(:ok)
    |> json(%{data: "Seeding not needed."})
  end

  def seed(conn, _params) do
    now = DateTime.utc_now()

    products = seed_products(100)
    users = seed_users(10_000)
    seed_orders(30_000, users, products)
    seed_reviews(5_000, users, products)

    done = DateTime.utc_now()
    elapsed_ms = DateTime.diff(done, now, :millisecond)

    conn
    |> put_status(:ok)
    |> json(%{data: "Database seeding complete in #{elapsed_ms}ms."})
  end

  defp seed_products(count) do
    products =
      Enum.map(1..count, fn _ ->
        %{
          name: Faker.Commerce.product_name(),
          description: Faker.Lorem.paragraph(),
          price: (:rand.uniform() * 1000) |> Float.round(2),
          inserted_at: Faker.NaiveDateTime.backward(365) |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    # Because of the length that these can get to, we may run into Postgrex limits, so we chunk_insert them
    chunk_insert_all(Product, products)
  end

  defp seed_users(count) do
    users =
      Enum.map(1..count, fn _ ->
        %{
          name: Faker.Person.name(),
          address: Faker.Address.street_address(),
          inserted_at: Faker.NaiveDateTime.backward(365) |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    chunk_insert_all(User, users)
  end

  defp seed_orders(count, users, products) do
    orders =
      Enum.map(1..count, fn _ ->
        user_id = Enum.random(users).id
        product = Enum.random(products)
        quantity = Enum.random(1..5)

        %{
          date: Faker.DateTime.backward(365) |> DateTime.truncate(:second),
          user_id: user_id,
          product_id: product.id,
          quantity: quantity,
          total_price: (quantity * product.price) |> Float.round(2),
          inserted_at: Faker.NaiveDateTime.backward(365) |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    chunk_insert_all(Order, orders)
  end

  defp seed_reviews(count, users, products) do
    reviews =
      Enum.map(1..count, fn _ ->
        %{
          product_id: Enum.random(products).id,
          user_id: Enum.random(users).id,
          rating: Enum.random(1..5),
          content: Faker.Lorem.paragraph(),
          inserted_at: Faker.NaiveDateTime.backward(365) |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.local_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    chunk_insert_all(Review, reviews)
  end

  defp chunk_insert_all(model, data) do
    # chunk down to avoid postgrex max parameters of 65535
    # this doesn't cleanly map to parameter numbers: multiply by the number of fields that each model has to get number of params
    chunk_size = 2000

    Enum.chunk_every(data, chunk_size)
    |> Enum.flat_map(fn chunk ->
      # the 'returning: true' kwlist will return the entire inserted record
      {_, inserted} = Repo.insert_all(model, chunk, returning: true)
      inserted
    end)
  end
end
