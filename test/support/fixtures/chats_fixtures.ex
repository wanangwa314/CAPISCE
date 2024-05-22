defmodule ChatApp.ChatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ChatApp.Chats` context.
  """

  @doc """
  Generate a chat.
  """
  def chat_fixture(attrs \\ %{}) do
    {:ok, chat} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> ChatApp.Chats.create_chat()

    chat
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        text: "some text",
        type: "some type"
      })
      |> ChatApp.Chats.create_message()

    message
  end
end
