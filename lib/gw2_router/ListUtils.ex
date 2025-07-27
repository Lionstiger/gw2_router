defmodule ListUtils do
  @moduledoc """
  Utility functions for lists, including generating permutations.
  """

  @spec permutations(list()) :: list(list())
  def permutations([]) do
    [[]]
  end

  def permutations(list) do
    for h <- list, t <- permutations(List.delete(list, h)), do: [h | t]
  end

  def permutations_fixed_first([]), do: [[]]

  def permutations_fixed_first([head | tail]) do
    for perm <- permutations(tail), do: [head | perm]
  end
end
