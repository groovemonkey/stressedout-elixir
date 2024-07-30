defmodule StressedoutWeb.OrderJSON do
  alias Stressedout.Orders.Order

  @doc """
  Renders a list of orders.
  """
  def index(%{orders: orders}) do
    %{data: for(order <- orders, do: data(order))}
  end

  @doc """
  Renders a single order.
  """
  def show(%{order: order}) do
    %{data: data(order)}
  end

  defp data(%Order{} = order) do
    %{
      id: order.id,
      user_id: order.user_id,
      product_id: order.product_id,
      quantity: order.quantity,
      total_price: order.total_price,
      date: order.date
    }
  end
end
