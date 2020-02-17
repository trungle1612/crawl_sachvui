defmodule Crawler.SachVui.CategoryDetail do
  alias Crawler.SachVui.Base
  def all_link do
    category_page()
    |> Enum.map(&link_book_per_page(&1))
    |> List.flatten()
    |> write_file()
  end

  def link_book_per_page(url) do
    IO.puts "Reading url: #{url}"
    {status, body} = Base.read_url(url)

    if status == :ok do
      {:ok, document} = Floki.parse_document(body)
      Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div > a")
      |> List.flatten()
      |> Enum.map(&format_elm(&1))
    else
      IO.puts "Error"
    end
  end

  # Private
  defp format_elm(elm) do
    {_, [{_, url}, _], [{_, [{_, photo_url}, {_, title}], _} ]} = elm
    %{title: title, photo: photo_url, url: url}
  end

  defp category_page do
    File.read!('data/category_links.txt')
    |> :erlang.binary_to_term
  end

  defp write_file(file) do
    File.write!("data/book_links.txt", :erlang.term_to_binary(file))
  end
end
