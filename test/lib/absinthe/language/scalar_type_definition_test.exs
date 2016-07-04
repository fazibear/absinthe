defmodule Absinthe.Language.ScalarTypeDefinitionTest do
  use Absinthe.Case, async: true

  alias Absinthe.Blueprint

  describe "converting to Blueprint" do

    it "works, given an IDL 'scalar' definition" do
      assert %Blueprint.IDL.ScalarTypeDefinition{name: "Time"} = from_input("scalar Time")
    end

    it "works, given an IDL 'scalar' definition with a directive" do
      rep = """
      scalar Time @description(text: "A datetime with a timezone")
      """ |> from_input
      assert %Blueprint.IDL.ScalarTypeDefinition{name: "Time", directives: [%{name: "description"}]} = rep
    end


  end

  defp from_input(text) do
    {:ok, doc} = Absinthe.Phase.Parse.run(text)

    doc
    |> extract_ast_node
    |> Blueprint.Draft.convert(doc)
  end

  defp extract_ast_node(%Absinthe.Language.Document{definitions: [node]}) do
    node
  end

end