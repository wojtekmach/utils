defmodule Hash do
  @moduledoc """
  Functions for computing hashes.
  """

  @spec sha256(binary() | Enumerable.t() | IO.device()) :: binary()
  @doc """
  Computes a SHA256 hash of `input`.

  Same as `hash(:sha256, input)`.
  """
  def sha256(input) do
    hash(:sha256, input)
  end

  @doc """
  Computes a hash of a binary, an enumerable, or an IO device.

  ## Examples

      iex> Hash.hash(:md5, "foo") |> Base.encode16()
      "ACBD18DB4CC2F85CEDEF654FCCC4A4D8"

      iex> Hash.hash(:md5, ["f", "o", "o"]) |> Base.encode16()
      "ACBD18DB4CC2F85CEDEF654FCCC4A4D8"

      iex> StringIO.open("foo", [], fn pid ->
      ...>   Hash.hash(:md5, pid) |> Base.encode16()
      ...> end)
      {:ok, "ACBD18DB4CC2F85CEDEF654FCCC4A4D8"}

  """
  @spec hash(:crypto.hash_algorithm(), binary() | Enumerable.t() | IO.device()) :: binary()
  def hash(type, input)

  def hash(type, binary) when is_binary(binary) do
    :crypto.hash(type, binary)
  end

  def hash(type, device) when is_atom(device) or is_pid(device) do
    hash(type, IO.stream(device, 4 * 1024))
  end

  def hash(type, enumerable) do
    enumerable
    |> Enum.reduce(:crypto.hash_init(type), &:crypto.hash_update(&2, &1))
    |> :crypto.hash_final()
  end
end
