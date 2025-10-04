defmodule MittelUsers.Repo.Migrations.DropIsEnabledColumn do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :is_enabled
    end
  end
end
