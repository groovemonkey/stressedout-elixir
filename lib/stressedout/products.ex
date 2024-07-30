defmodule Stressedout.Products do
  @moduledoc """
  The Products context.
  """

  import Ecto.Query, warn: false
  alias Stressedout.Repo

  alias Stressedout.Products.Product
  alias Stressedout.Orders.Order

  @doc """
  Get a random product.
  """
  def get_random_product do
    query =
      from p in Product,
        order_by: fragment("RANDOM()"),
        limit: 1

    case Repo.one(query) do
      nil -> {:error, :not_found}
      product -> {:ok, product}
    end
  end

  @doc """
  Return a count of how many orders have been placed for a product.
  """
  def count_distinct_purchasers(product_id) do
    query =
      from o in Order,
        where: o.product_id == ^product_id,
        select: count(o.user_id, :distinct)

    case Repo.one(query) do
      nil -> {:error, :not_found}
      count -> {:ok, count}
    end
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
