defmodule ExAirtable.Phoenix.Model do
  @moduledoc """
  A behaviour for using Ecto-validated Airtable models in an Elixir App.

  Add `use ExAirtable.Phoenix.Model` to any model that implements both Airtable and Ecto schema validation. 

  The advantage of this behaviour is to allow you to use generic patterns to query all models using the same methods. See `ExAirtable.Phoenix.Repo` for more details about some of the methods you can call with models that implement this behaviour.
  """

  @callback validate(map()) :: {:ok, map()} | {:error, Ecto.Changeset.t()}

  defmacro __using__(_) do
    quote do
      use ExAirtable.Table
      use Ecto.Schema

      import Ecto.Changeset
      import ExAirtable.Phoenix.Validators

      @behaviour ExAirtable.Phoenix.Model

      # Ecto embedded schemas include primary key by default
      @primary_key false
    end
  end
end
