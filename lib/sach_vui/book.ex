defmodule Crawler.SachVui.Book do
  alias Crawler.SachVui.BookContent
  alias Crawler.SachVui.Base

  def download do
    book_links()
    |> Enum.map(&parse_info(&1.url, &1.photo))
    |> Enum.each(fn info ->
      {title, category, url, photo} = info
      BookContent.write(title, category, url, photo)
    end)
  end

  defp parse_info(url, photo) do
    {status, body} = Base.read_url(url)
    IO.write("Reading: #{url}")

    if status == :ok do
      {:ok, document} = Floki.parse_document(body)
      [{_, _, [title]}] = Floki.find(document, "body > div.container > div.row > div.col-md-9 > div:nth-child(1) > div > div.row.thong_tin_ebook > div.col-md-8 > a:nth-child(1) > h1")
      [{_, _, [category]}] = Floki.find(document, "body > div.container > div.row > div.col-md-9 > div:nth-child(1) > div > div.row.thong_tin_ebook > div.col-md-8 > h5:nth-child(4) > a")

      {title, category, url, photo}
    else
      {"", "", ""}
    end
  end

  defp book_links do
    File.read!("data/book_links.txt") |> :erlang.binary_to_term
  end

  def create_category_folder(category) do
    if !File.dir?("data/#{category}"), do: File.mkdir("data/#{category}")
  end
end
