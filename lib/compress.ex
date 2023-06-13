defmodule Compress do
  @moduledoc """
  Functions for compressing and decompressing iodata and streams.
  """

  def gzip(iodata) do
    :zlib.gzip(iodata)
  end

  def gzip_stream(enumerable) do
    eof = make_ref()

    enumerable
    |> Stream.concat([eof])
    |> Stream.transform(
      fn ->
        # https://github.com/erlang/otp/blob/OTP-26.0/erts/preloaded/src/zlib.erl#L548:L558
        z = :zlib.open()
        :ok = :zlib.deflateInit(z, :default, :deflated, 16 + 15, 8, :default)
        z
      end,
      fn
        ^eof, z ->
          buf = :zlib.deflate(z, [], :finish)
          {buf, z}

        decompressed, z ->
          buf = :zlib.deflate(z, decompressed)
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

  def gunzip_stream(enumerable) do
    # https://github.com/erlang/otp/blob/OTP-26.0/erts/doc/src/zlib.xml#L722:L733
    Stream.transform(
      enumerable,
      fn ->
        z = :zlib.open()
        :ok = :zlib.inflateInit(z, 16 + 15)
        z
      end,
      fn compressed, z ->
        enumerable =
          Stream.resource(
            fn ->
              :zlib.safeInflate(z, compressed)
            end,
            fn
              {:continue, decompressed} ->
                {decompressed, :zlib.safeInflate(z, [])}

              {:finished, decompressed} ->
                {decompressed, :halt}

              :halt ->
                {:halt, nil}
            end,
            & &1
          )

        {enumerable, z}
      end,
      fn z ->
        :ok = :zlib.inflateEnd(z)
        :ok = :zlib.close(z)
      end
    )
  end
end
