defmodule Absinthe.Language.ObjectTypeDefinitionTest do
  use Absinthe.Case, async: true

  alias Absinthe.Blueprint

  describe "converting to Blueprint" do

    it "works, given an IDL 'type' definition" do
      assert %Blueprint.IDL.ObjectTypeDefinition{name: "Person"} = from_input("type Person { name: String! }")
    end

    it "works, given an IDL 'type' definition and a directive" do
      rep = """
      type Person
      @description(text: "A person")
      {
        name: String!
      }
      """ |> from_input
      assert %Blueprint.IDL.ObjectTypeDefinition{name: "Person", directives: [%{name: "description"}]} = rep
    end

    it "works, given an IDL 'type' definition that implements an interface" do
      rep = """
      type Person implements Entity {
        name: String!
      }
      """ |> from_input
      assert %Blueprint.IDL.ObjectTypeDefinition{name: "Person", interfaces: [%Blueprint.NamedType{name: "Entity"}]} = rep
    end

    it "works, given an IDL 'type' definition that implements an interface and uses a directive" do
      rep = """
      type Person implements Entity
      @description(text: "A person entity")
      {
        name: String!
      }
      """ |> from_input
      assert %Blueprint.IDL.ObjectTypeDefinition{name: "Person", interfaces: [%Blueprint.NamedType{name: "Entity"}], directives: [%{name: "description"}]} = rep
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