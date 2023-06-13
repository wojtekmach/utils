defmodule CompressTest do
  use ExUnit.Case, async: true
  doctest Compress

  test "gzip/1" do
    binary = "foo\nbar\nbaz"
    assert binary |> Compress.gzip() |> Compress.gunzip() == binary
  end

  test "gzip_stream/1" do
    binary = String.duplicate("foo\nbar\nbaz\n", 100 * 1024)
    {:ok, pid} = StringIO.open(binary)
    stream = IO.stream(pid, :line)

    assert stream
           |> Compress.gzip_stream()
           |> Compress.gunzip_stream()
           |> Enum.to_list()
           |> IO.iodata_to_binary() ==
             binary
  end
end
