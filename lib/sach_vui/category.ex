defmodule Crawler.SachVui.Category do
  alias Crawler.SachVui.Base
  @url "https://sachvui.com/"
  @file_path "data/category.txt"

  def parse do
    {status, body} = Base.read_url(@url)

    if status == :ok do
      {:ok, document} = Floki.parse_document(body)
      Floki.find(document, "body > div.container > div.jumbotron.trangchu > ul > li")
      |> Stream.map(&Floki.find(&1, "a"))
      |> Enum.map(fn x ->
        [{_tag, link, text}] = x
        get_url_and_title{link, text}
      end)
    else
      IO.puts "Error"
    end
  end

  def write_file do
    file = File.open!(@file_path, [:write, :utf8])
    parse() |> Enum.each(fn x ->
      { title, url } = x
      case IO.write(file, "#{title} | #{url}\n") do
        :ok -> "Successfully"
        _ -> "Faild"
      end
    end)

    File.close(file)
  end

  defp get_url_and_title(row) do
    {link, text } = row
    [{_tag, url}] = link
    [_, title] = text

    {title, url}
  end
end
