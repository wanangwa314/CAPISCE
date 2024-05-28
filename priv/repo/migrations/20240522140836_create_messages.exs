defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string
      add :type, :string

      add :chat_id, references(:chats)
      timestamps(type: :utc_datetime)
    end
  end
end
