defmodule ZlibTest do
  use ExUnit.Case, async: true

  test "gzip/1" do
    plain = "foo\nbar\nbaz"

    {:ok, pid} = StringIO.open(plain)
    stream = IO.stream(pid, :line)

    assert stream |> Zlib.gzip() |> Enum.to_list() |> Zlib.gunzip() == plain
  end
end
