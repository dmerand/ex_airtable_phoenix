# ExAirtablePhoenix

A set of sensible defaults for using [ExAirtable](https://github.com/exploration/ex_airtable) with Phoenix, using Ecto's embedded schemas for validation.

Because `ExAirtable` returns general-purpose structs that conform to the Airtable API specifications, it's often nice to be able to further validate those structs to domain-specific models. For example, `ExAirtable` might return something like this for your "blogging" app:

```elixir
%ExAirtable.Airtable.Record{
  createdTime: "2016-05-20T01:00:23.000Z",
  fields: %{
    "Email" => "my@email.org",
    "Comments" => ["recg6cWUjaSxrShNy", "recE2sCYzvbgbDUAZ",
     "recJyXQOKlQRS38n7"],
    "Name" => "Some App User",
    "Useless Field" => "Whatever"
  },
  id: "recIbeH41sLn4nF6t"
}
```

...when what you really want is something more like this:

```elixir
%MyApp.User{
  name: "Some App User",
  email: "my@email.org",
  comments: [%MyApp.Comment{}, %MyApp.Comment{}, ...]
}
```

The thinking is, since Ecto has [such nice embedded schema support](https://hexdocs.pm/ecto/Ecto.Schema.html#content), why reinvent the wheel? This library allows you to do a relatively small amount of setup by defining models that link to Airtable, optionally filter the resulting values, and then use Ecto embedded schemas to validate and cast them into domain models.

Continuing the above "blogging" app example, you might have a model defined like this:

```elixir
defmodule MyApp.User do
  use ExAirtable.Phoenix.Model
  
  # Details about your Base
  def base do
    %ExAirtable.Config.Base{
      api_key: "your key",
      id: "your base ID"
    }
  end

  # This would be the name of the table in your Airtable base
  @impl ExAirtable.Table
  def name, do: "Users"

  # Convert the Airtable field names to your app's field names.
  @impl ExAirtable.Table
  def schema do
    %{
      "Email" => :email,
      "First Name" => :first_name,
      "Last Name" => :last_name
    }
  end

  # This is Ecto, doing the work of casting and schema definition
  embedded_schema do
    field(:airtable_id, :string)
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
  end

  @doc """
  Returns a `%User{}` given a valid set of attributes.
  On failure, returns `{:error, %Ecto.Changeset{}}`
  """
  @impl ExAirtable.Phoenix.Model
  def validate(attrs \\ %{}) do
    %__MODULE__{}
    |> cast(attrs, [:airtable_id, :email, :first_name, :last_name])
    |> validate_required([:airtable_id, :email, :first_name])
    |> apply_action(:save)
  end
end
```

Once you've defined your model object this way, you can use the functions in `ExAirtable.Phoenix.Repo` to automatically retrieve, convert, etc. items out of your ExAirtable cache:

```elixir
defmodule MyApp.UserContext do
  alias ExAirtable.Phoenix.Repo
  alias MyApp.User
  
  @doc """
  Find a User by email

  Returns `{:ok, %User{}}` on success.

  Returns `{:error, :not_found}` on failure.
  """
  def find_by_email(email) do
    if user = Repo.one(User, :email, email) do
        {:ok, user}
    else
        {:error, :not_found}
    end
  end

  @doc """
  List all valid users
  """
  def list_users do
    Repo.all(User)
  end
end
```

Be sure to check out `ExAirtable.Phoenix.Repo` for more details and examples.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `ex_airtable_phoenix` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_airtable_phoenix, "~> 0.1.0"}
  ]
end
```

If you prefer to use the latest build, point straight to github:

```elixir
  [
    {:ex_airtable_phoenix, git: "https://github.com/exploration/ex_airtable_phoenix.git"}
  ]
```

## Documentation

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_airtable_phoenix](https://hexdocs.pm/ex_airtable_phoenix).
