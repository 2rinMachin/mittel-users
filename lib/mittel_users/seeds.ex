defmodule MittelUsers.Seeds do
  alias MittelUsers.Repo
  alias MittelUsers.Users.Adapter.EctoUser
  alias Bcrypt

  def ensure_admin_user do
    email = System.get_env("DEFAULT_ADMIN_EMAIL")
    username = System.get_env("DEFAULT_ADMIN_USERNAME")
    password = System.get_env("DEFAULT_ADMIN_PASSWORD")

    if email && username && password do
      Repo.insert!(
        %EctoUser{
          email: email,
          username: username,
          password_hash: Bcrypt.hash_pwd_salt(password),
          role: :admin
        },
        on_conflict: :nothing,
        conflict_target: :email
      )
    else
      IO.puts("[WARN] Admin seed skipped: missing DEFAULT_ADMIN_* environment variables")
    end
  end
end
