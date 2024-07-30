defmodule Stressedout.UsersTest do
  use Stressedout.DataCase

  alias Stressedout.Users

  describe "users" do
    alias Stressedout.Users.User

    import Stressedout.UsersFixtures

    @invalid_attrs %{id: nil, name: nil, address: nil}

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Users.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{id: "7488a646-e31f-11e4-aace-600308960662", name: "some name", address: "some address"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.id == "7488a646-e31f-11e4-aace-600308960662"
      assert user.name == "some name"
      assert user.address == "some address"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      update_attrs = %{id: "7488a646-e31f-11e4-aace-600308960668", name: "some updated name", address: "some updated address"}

      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.id == "7488a646-e31f-11e4-aace-600308960668"
      assert user.name == "some updated name"
      assert user.address == "some updated address"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, @invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
