defmodule Stressedout.OrdersTest do
  use Stressedout.DataCase

  alias Stressedout.Orders

  describe "orders" do
    alias Stressedout.Orders.Order

    import Stressedout.OrdersFixtures

    @invalid_attrs %{id: nil, date: nil, user_id: nil, product_id: nil, quantity: nil, total_price: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{id: "7488a646-e31f-11e4-aace-600308960662", date: ~U[2024-07-29 00:30:00Z], user_id: "7488a646-e31f-11e4-aace-600308960662", product_id: "7488a646-e31f-11e4-aace-600308960662", quantity: 42, total_price: 120.5}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.id == "7488a646-e31f-11e4-aace-600308960662"
      assert order.date == ~U[2024-07-29 00:30:00Z]
      assert order.user_id == "7488a646-e31f-11e4-aace-600308960662"
      assert order.product_id == "7488a646-e31f-11e4-aace-600308960662"
      assert order.quantity == 42
      assert order.total_price == 120.5
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{id: "7488a646-e31f-11e4-aace-600308960668", date: ~U[2024-07-30 00:30:00Z], user_id: "7488a646-e31f-11e4-aace-600308960668", product_id: "7488a646-e31f-11e4-aace-600308960668", quantity: 43, total_price: 456.7}

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.id == "7488a646-e31f-11e4-aace-600308960668"
      assert order.date == ~U[2024-07-30 00:30:00Z]
      assert order.user_id == "7488a646-e31f-11e4-aace-600308960668"
      assert order.product_id == "7488a646-e31f-11e4-aace-600308960668"
      assert order.quantity == 43
      assert order.total_price == 456.7
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
