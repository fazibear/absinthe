defmodule Absinthe.Phase.Document.Arguments.NormalizeTest do
  use Absinthe.Case, async: true

  alias Absinthe.{Blueprint, Phase, Pipeline}

  defmodule Schema do
    use Absinthe.Schema

    query do
      field :foo, :foo do
        arg :id, non_null(:id)
      end
      field :profile, :user do
        arg :name, :string
        arg :age, :integer
      end
    end

    object :foo do
      field :bar, :string
    end

    object :user do
      field :id, non_null(:id)
      field :name, non_null(:string)
      field :age, :integer
    end

  end

  @pre_pipeline Enum.take_while(Pipeline.for_document(Schema, %{}), fn
    {Phase.Document.Variables, _} ->
      false
    _ ->
      true
  end)

  @query """
    query Foo($id: ID!) {
      foo(id: $id) {
        bar
      }
    }
    query Profile($age: Int = 36) {
      profile(name: "Bruce", age: $age) {
        id
      }
    }
  """

  describe "when not providing a value for an optional variable with a default value" do
    it "uses the default value" do
      result = input(@query, %{})
      op = result.operations |> Enum.find(&(&1.name == "Profile"))
      field = op.selections |> List.first
      age_argument = field.arguments |> Enum.find(&(&1.name == "age"))
      assert %Blueprint.Input.Integer{value: 36} == age_argument.normalized_value
      name_argument = field.arguments |> Enum.find(&(&1.name == "name"))
      assert %Blueprint.Input.String{value: "Bruce"} == name_argument.normalized_value
    end
  end

  describe "when providing a value for an optional variable with a default value" do
    it "uses the default value" do
      result = input(@query, %{"age" => 4})
      op = result.operations |> Enum.find(&(&1.name == "Profile"))
      field = op.selections |> List.first
      age_argument = field.arguments |> Enum.find(&(&1.name == "age"))
      assert %Blueprint.Input.Integer{value: 4} == age_argument.normalized_value
      name_argument = field.arguments |> Enum.find(&(&1.name == "name"))
      assert %Blueprint.Input.String{value: "Bruce"} == name_argument.normalized_value
    end
  end

  def input(query, values) do
    {:ok, result} = blueprint(query, values)
    |> Phase.Document.Arguments.Normalize.run

    result
  end

  defp blueprint(query, values) do
    {:ok, blueprint} = Pipeline.run(query, @pre_pipeline ++ [{Phase.Document.Variables, values}])
    blueprint
  end

end