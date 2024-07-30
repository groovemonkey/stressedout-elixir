defmodule StressedoutWeb.OrderControllerTest do
  use StressedoutWeb.ConnCase

  import Stressedout.OrdersFixtures

  alias Stressedout.Orders.Order

  @create_attrs %{
    id: "7488a646-e31f-11e4-aace-600308960662",
    date: ~U[2024-07-29 00:30:00Z],
    user_id: "7488a646-e31f-11e4-aace-600308960662",
    product_id: "7488a646-e31f-11e4-aace-600308960662",
    quantity: 42,
    total_price: 120.5
  }
  @update_attrs %{
    id: "7488a646-e31f-11e4-aace-600308960668",
    date: ~U[2024-07-30 00:30:00Z],
    user_id: "7488a646-e31f-11e4-aace-600308960668",
    product_id: "7488a646-e31f-11e4-aace-600308960668",
    quantity: 43,
    total_price: 456.7
  }
  @invalid_attrs %{id: nil, date: nil, user_id: nil, product_id: nil, quantity: nil, total_price: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all orders", %{conn: conn} do
      conn = get(conn, ~p"/api/orders")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create order" do
    test "renders order when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "date" => "2024-07-29T00:30:00Z",
               "id" => "7488a646-e31f-11e4-aace-600308960662",
               "product_id" => "7488a646-e31f-11e4-aace-600308960662",
               "quantity" => 42,
               "total_price" => 120.5,
               "user_id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/orders", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update order" do
    setup [:create_order]

    test "renders order when data is valid", %{conn: conn, order: %Order{id: id} = order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/orders/#{id}")

      assert %{
               "id" => ^id,
               "date" => "2024-07-30T00:30:00Z",
               "id" => "7488a646-e31f-11e4-aace-600308960668",
               "product_id" => "7488a646-e31f-11e4-aace-600308960668",
               "quantity" => 43,
               "total_price" => 456.7,
               "user_id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, order: order} do
      conn = put(conn, ~p"/api/orders/#{order}", order: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete order" do
    setup [:create_order]

    test "deletes chosen order", %{conn: conn, order: order} do
      conn = delete(conn, ~p"/api/orders/#{order}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/orders/#{order}")
      end
    end
  end

  defp create_order(_) do
    order = order_fixture()
    %{order: order}
  end
end
