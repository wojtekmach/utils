defmodule Hash do
  @moduledoc """
  Functions for computing hashes.
  """

  @doc """
  Computes a hash of the input.

  ## Examples

      iex> ["foo\\n", "bar\\n"] |> Hash.hash(:md5) |> Base.encode16()
      "F47C75614087A8DD938BA4ACFF252494"

      iex> {:ok, pid} = StringIO.open("foo\\nbar\\n")
      iex> stream = IO.stream(pid, :line)
      iex> stream |> Hash.hash(:md5) |> Base.encode16()
      "F47C75614087A8DD938BA4ACFF252494"

  """
  @spec hash(iodata() | Enumerable.t(), :crypto.hash_algorithm()) :: binary()
  def hash(iodata_or_enumerable, type)

  def hash(iodata, type) when is_binary(iodata) or is_list(iodata) do
    :crypto.hash(type, iodata)
  end

  def hash(enumerable, type) do
    enumerable
    |> Enum.reduce(:crypto.hash_init(type), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
  end
end
