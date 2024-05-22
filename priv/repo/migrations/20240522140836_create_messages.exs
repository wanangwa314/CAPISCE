defmodule ChatApp.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string
      add :type, :string

      timestamps(type: :utc_datetime)
    end
  end
end
