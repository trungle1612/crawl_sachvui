defmodule Crawler.SachVui.Category do
  @url "https://sachvui.com/"
  @file_path "data/category.txt"

  def scraper do
    case HTTPoison.get @url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        nil
    end
  end

  def parse do
    {:ok, document} = Floki.parse_document(scraper())
    # [{tag, link, text}]
    Floki.find(document, "body > div.container > div.jumbotron.trangchu > ul > li")
    |> Stream.map(&Floki.find(&1, "a"))
    |> Enum.map(fn x ->
      [{_tag, link, text}] = x
      get_url_and_title{link, text}
    end)
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
  end

  def get_url_and_title(row) do
    {link, text } = row
    [{_tag, url}] = link
    [_, title] = text

    {title, url}
  end
end
