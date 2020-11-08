defmodule ExAirtable.Phoenix.Validators do
  @moduledoc """
  Validation functions that will be automatically included when you use the `ExAirtable.Phoenix.Model` module.
  """

  @doc """
  Ensure that at least one of a given list of fields has data.

  `fields` should be a list of atoms, eg: `[:text, :description, :url]`.
  """
  def validate_one_of(changeset, fields \\ []) do
    values = Enum.map(fields, &Ecto.Changeset.get_field(changeset, &1))

    if Enum.any?(values, &(&1 && &1 != [])) do
      changeset
    else
      Enum.reduce(fields, changeset, fn field, acc ->
        Ecto.Changeset.add_error(acc, field, "must have something")
      end)
    end
  end
end
