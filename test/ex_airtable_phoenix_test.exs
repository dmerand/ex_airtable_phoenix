defmodule ExAirtable.PhoenixTest do
  use ExUnit.Case
  use ExAirtable.Phoenix.Model

  def name, do: "neat"
  def base, do: %{}
  def validate(_attrs), do: %{}

  embedded_schema do
    field(:wat, :string)
  end

  test "basically that this compiles" do
    assert true
  end
end
