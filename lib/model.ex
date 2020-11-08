defmodule ExAirtable.Phoenix.Model do
  @moduledoc """
  A behaviour for using Ecto-validated Airtable models in an Elixir App.

  Add `use ExAirtable.Phoenix.Model` to any model that implements both Airtable and Ecto schema validation. 

  The advantage of this behaviour is to allow you to use generic patterns to query all models using the same methods. See `ExAirtable.Phoenix.Repo` for more details about some of the methods you can call with models that implement this behaviour.

  If you like, you can pass the `otp_app` option when you use this module. Assuming this points to your app, and you've configured your `confix.exs` with an appropriate entry (see `README.md` for details), your base configuration will be imported without further configuration.
  """

  @callback validate(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}

  defmacro __using__(opts \\ nil) do
    quote do
      use ExAirtable.Table
      use Ecto.Schema
      import Ecto.Changeset
      import ExAirtable.Phoenix.Validators

      @behaviour ExAirtable.Phoenix.Model
      @primary_key false
    end

    if app = Keyword.get(opts, :otp_app) do
      quote bind_quoted: [app: app] do
        @impl ExAirtable.Table
        def base do
          struct(
            ExAirtable.Config.Base,
            Application.get_env(unquote(app), ExAirtable.Phoenix)
          )
        end
      end
    end
  end
end
