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
end
