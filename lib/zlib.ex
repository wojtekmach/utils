defmodule Zlib do
  def gzip(iodata_or_enumerable)

  def gzip(iodata) when is_binary(iodata) or is_list(iodata) do
    :zlib.gzip(iodata)
  end

  def gzip(enumerable) do
    eof = make_ref()

    enumerable
    |> Stream.concat([eof])
    |> Stream.transform(
      fn ->
        z = :zlib.open()
        # https://github.com/erlang/otp/blob/OTP-24.0-rc1/erts/preloaded/src/zlib.erl#L543
        :ok = :zlib.deflateInit(z, :default, :deflated, 16 + 15, 8, :default)
        z
      end,
      fn
        ^eof, z ->
          buf = :zlib.deflate(z, [], :finish)
          {buf, z}

        data, z ->
          buf = :zlib.deflate(z, data)
          {buf, z}
      end,
      fn z ->
        :ok = :zlib.deflateEnd(z)
        :ok = :zlib.close(z)
      end
    )
  end

  def gunzip(iodata) do
    :zlib.gunzip(iodata)
  end
end
