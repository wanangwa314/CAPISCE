defmodule ChatApp.Chats.Message do
  use Ecto.Schema
  import Ecto.Changeset

  alias ChatApp.Chats.Chat

  schema "messages" do
    field :text, :string
    field :type, :string

    belongs_to :chat, Chat, foreign_key: :chat_id, type: :id
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :type, :chat_id])
    |> validate_required([:text, :type])
  end
end
