defmodule Conformance.AuthController do
  use Phoenix.Controller
  use Conformance, :verified_routes

  require Logger

  alias Oidcc.ClientContext
  alias Oidcc.ProviderConfiguration
  alias Oidcc.Token

  plug Oidcc.Plug.AuthorizationCallback,
       [
         provider: Conformance.ConfigWorker,
         client_id: &Conformance.RegisterClient.client_id/0,
         client_secret: &Conformance.RegisterClient.client_secret/0,
         client_context_opts: &Conformance.RegisterClient.client_context_opts/0,
         client_profile_opts: Conformance.RegisterClient.client_profile_opts(),
         redirect_uri: &__MODULE__.redirect_url/0
       ]
       when action in [:callback]

  plug Oidcc.Plug.Authorize,
       [
         provider: Conformance.ConfigWorker,
         client_id: &Conformance.RegisterClient.client_id/0,
         client_secret: &Conformance.RegisterClient.client_secret/0,
         client_context_opts: &Conformance.RegisterClient.client_context_opts/0,
         client_profile_opts: Conformance.RegisterClient.client_profile_opts(),
         redirect_uri: &__MODULE__.redirect_url/0,
         scopes: ["openid", "profile"]
       ]
       when action in [:authorize]

  def authorize(conn, _params), do: conn

  def callback_form(conn, %{"code" => code}) do
    # Redirect neccesary since session does not include nonce
    # on cross origin post
    redirect(conn, to: ~p"/callback?code=#{code}")
  end

  def callback(
        %Plug.Conn{
          private: %{
            Oidcc.Plug.AuthorizationCallback => {:ok, {token, userinfo}}
          }
        } = conn,
        _params
      ) do
    Logger.info("Retrieved Token: #{inspect(token, pretty: true)}")
    Logger.info("Retrieved Userinfo: #{inspect(userinfo, pretty: true)}")

    provider_configuration =
      Oidcc.ProviderConfiguration.Worker.get_provider_configuration(Conformance.ConfigWorker)

    {:ok, client_context} =
      ClientContext.from_configuration_worker(
        Conformance.ConfigWorker,
        Conformance.RegisterClient.client_id(),
        Conformance.RegisterClient.client_secret(),
        Conformance.RegisterClient.client_context_opts()
      )

    conn =
      with {:ok, {refreshed_token, refreshed_userinfo}} <-
             maybe_refresh(token, provider_configuration),
           {:ok, accounts_response} <- maybe_call_accounts(token, client_context) do
        Logger.info("Refreshed Token: #{inspect(refreshed_token, pretty: true)}")
        Logger.info("Refreshed Userinfo: #{inspect(refreshed_userinfo, pretty: true)}")
        Logger.info("Accounts Response: #{inspect(accounts_response, pretty: true)}")

        if is_binary(provider_configuration.end_session_endpoint) do
          target_uri = url(~p"/logged-out")

          {:ok, redirect_uri} =
            Oidcc.initiate_logout_url(
              token,
              Conformance.ConfigWorker,
              Conformance.RegisterClient.client_id(),
              %{post_logout_redirect_uri: target_uri, state: "example_state"}
            )

          redirect(conn, external: IO.iodata_to_binary(redirect_uri))
        else
          send_resp(conn, 200, "OK")
        end
      else
        {:error, reason} -> error_response(conn, reason)
      end

    spawn(fn ->
      Process.sleep(2_000)

      Conformance.Screenshot.take()
      Process.send(Conformance.Runner, :stop, [])
    end)

    conn
  end

  def callback(
        %Plug.Conn{
          private: %{
            Oidcc.Plug.AuthorizationCallback => {:error, reason}
          }
        } = conn,
        _params
      ) do
    conn = error_response(conn, reason)

    spawn(fn ->
      Process.sleep(2_000)

      Conformance.Screenshot.take()
      Process.send(Conformance.Runner, :stop, [])
    end)

    conn
  end

  def logged_out(conn, params) do
    spawn(fn ->
      Process.sleep(2_000)

      Conformance.Screenshot.take()
      Process.send(Conformance.Runner, :stop, [])
    end)

    send_resp(conn, 200, inspect(%{params: params}, pretty: true))
  end

  def front_channel_log_out(conn, params) do
    Logger.info("""
    Received Frontchannel Log Out

    Params: #{inspect(params, pretty: true)}
    """)

    send_resp(conn, 200, inspect(%{params: params}, pretty: true))
  end

  defp maybe_refresh(
         %Token{refresh: %Token.Refresh{token: _refresh_token}} = token,
         %ProviderConfiguration{grant_types_supported: grant_types_supported}
       ) do
    if "refresh_token" in grant_types_supported do
      with {:ok, token} <-
             Oidcc.refresh_token(
               token,
               Conformance.ConfigWorker,
               Conformance.RegisterClient.client_id(),
               Conformance.RegisterClient.client_secret()
             ),
           {:ok, userinfo} <-
             Oidcc.retrieve_userinfo(
               token,
               Conformance.ConfigWorker,
               Conformance.RegisterClient.client_id(),
               Conformance.RegisterClient.client_secret(),
               %{}
             ) do
        Logger.info("Retrieved Token: #{inspect(token, pretty: true)}")
        Logger.info("Retrieved Userinfo: #{inspect(userinfo, pretty: true)}")

        {:ok, {token, userinfo}}
      end
    else
      {:ok, {nil, nil}}
    end
  end

  defp maybe_refresh(%Token{}, _config), do: {:ok, {nil, nil}}

  defp maybe_call_accounts(token, client_context) do
    accounts_uri = Application.get_env(:conformance, :call_accounts, false)

    if accounts_uri do
      headers =
        :oidcc_auth_util.add_authorization_header(
          token.access.token,
          token.access.type,
          :get,
          accounts_uri,
          %{},
          ClientContext.struct_to_record(client_context)
        )

      :oidcc_http_util.request(
        :get,
        {accounts_uri, headers},
        %{topic: [:conformance, :accounts]},
        %{}
      )
    else
      {:ok, nil}
    end
  end

  defp error_response(conn, reason) do
    Logger.error("OIDC Error: #{inspect(reason, pretty: true)}")

    send_resp(conn, 400, inspect(reason, pretty: true))
  end

  def redirect_url, do: url(~p"/callback")
end
