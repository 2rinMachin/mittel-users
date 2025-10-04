defmodule MittelUsers.Repo.Migrations.SwitchToUsername do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :first_name
      remove :last_name
      add :username, :string, null: false
    end

    create unique_index(:users, [:username])
  end
end
