defmodule ExAirtable.Phoenix.Repo do
  @moduledoc """
  Functions to deal with finding and converting `ExAirtable`
  structs into Ecto Schema-fied models for your app.

  Also contains helper functions for finding, filtering, and
  injecting fields and relationships from any model that implements the `ExAirtable.Phoenix.Model` behaviour.

  These methods roughly correspond to similar methods in the Ecto.Repo library, to ensure a smooth upgrade path for apps that want to move from Airtable to a hosted Postgres or other database back-end.
  """

  @doc """
  Return all valid model records from the Airtable cache.

  Pass in the name of the module that implements the `ExAirtable.Phoenix.Model` behaviour.

  Returns records from the model that pass validation. This might be a subset of the records that you find in Airtable, depending on how strict your validation is.
  """
  def all(module) when is_atom(module) do
    ExAirtable.list!(module)
    |> Map.get(:records)
    |> Enum.map(&module.to_schema/1)
    |> Enum.map(&module.validate/1)
    |> Enum.reduce([], fn result, acc ->
      case result do
        {:error, _} -> acc
        {:ok, record} -> [record | acc]
      end
    end)
  end

  @doc """
  Filter a list of model records to just the ones where `key` matches `value`.

  You can pass a pre-found list of records, or just the name of a model.

  Returns an empty list `[]` if nothing matches.

  ## Examples

      iex> get_by(MyApp.Posts.Comment, :airtable_id, "rec1234")
      [%MyApp.Posts.Comment{}, ...]
      
      iex> get_by(list_of_posts, :airtable_id, "rec1234")
      [%MyApp.Posts.Posts{}, ...]
  """
  def get_by(model, key, value)
      when is_atom(model) and is_atom(key) do
    get_by(all(model), key, value)
  end

  def get_by(list, key, value) when is_list(list) and is_atom(key) do
    Enum.filter(list, &(Map.get(&1, key) == value))
  end

  @doc """
  Filter all records from a given model to just the ones where one of the values at `key` matches `value`.

  Because Airtable deals with "many-to-many" fields and "multiple choice" fields by returning JSON arrays, it's helpful to have a way to find records where something in that array matches a particular value.

  You can pass a pre-found list of records, or just the name of a model.

  ## Examples

      iex> get_relationship(MyApp.Post.Comment, :user, my_user.airtable_id)
      [%MyApp.Posts.Comment{}, ...]

      iex> get_relationship(MyApp.Post.Post, :tags, "Tech")
      [%MyApp.Posts.Post{}, ...]
  """
  def get_relationship(records, key, value)
      when is_list(records) and is_atom(key) do
    Enum.filter(records, fn record ->
      case Map.get(record, key) do
        nil -> false
        tags -> Enum.any?(tags, &(&1 == value))
      end
    end)
  end

  def get_relationship(model, key, value)
      when is_atom(model) and is_atom(key) do
    get_relationship(all(model), key, value)
  end

  @doc """
  Replace Airtable "list of IDS" related field references with actual model objects.

  You can pass a pre-found list of records, or just the name of a model.

  ## Examples

      iex> inject_relationship(post, :comments, MyApp.Post.Comment)
      %MyApp.Posts.Post{comments: [%MyApp.Posts.Comment{}, ...]}
  """
  def inject_relationship(record, key, records)
      when is_map(record) and is_atom(key) and is_list(records) do
    relations =
      Map.get(record, key)
      |> Enum.map(fn id ->
        Enum.find(records, fn rr -> rr.airtable_id == id end)
      end)
      |> Enum.filter(& &1)

    Map.put(record, key, relations)
  end

  def inject_relationship(record, key, model)
      when is_map(record) and is_atom(key) and is_atom(model) do
    inject_relationship(record, key, all(model))
  end

  @doc """
  Same as `get_by/3` but only returns the first match.
  """
  def one(model, key, value) when is_atom(model) and is_atom(key) do
    get_by(model, key, value)
    |> Enum.at(0)
  end
end
