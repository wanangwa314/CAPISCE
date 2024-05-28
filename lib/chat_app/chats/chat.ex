defmodule ChatApp.Chats.Chat do
  use Ecto.Schema
  import Ecto.Changeset
  alias ChatApp.Chats.Message

  schema "chats" do
    field :name, :string
    field :ref_id, :string

    has_many :messages, Message
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :ref_id])
    |> validate_required([:name, :ref_id])
  end
end
