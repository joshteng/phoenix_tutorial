defmodule RumblWeb.Auth do
  @moduledoc """
  This is a module plug with other functionalities. According to plug, there must be 2 functions init/1 and conn/2
  """
  import Plug.Conn
  import Phoenix.Controller
  alias RumblWeb.Router.Helpers, as: Routes

  # Init runs only at compile time, the return value is passed to call
  def init(opts), do: opts

  # Runs at runtime, takes 2nd argument from the return RumblWeb.Auth.init/1
  def call(conn, _opts) do
    user_id = get_session(conn, :user_id) # get user_id from session
    user = user_id && Rumbl.Accounts.get_user(user_id) # get user from repo. Nil if no user_id or no user found
    assign(conn, :current_user, user) # setting conn.assigns field current_user to user found from DB. assign function comes from Plug.Conn
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn), do: configure_session(conn, drop: true)

  # def logout(conn, user_id), do: delete_session(conn, :user_id)

  # this essentially can be function plug
  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt() # where does halt() come from? from use RumblWeb, :controller I'm guessing and then Plug.Conn
    end
  end
end
