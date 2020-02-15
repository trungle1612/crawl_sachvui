defmodule Crawler.SachVui.CategoryDetail do
  def all_link do
    category_page()
    |> Enum.map(&link_book_per_page(&1))
    |> List.flatten()
    |> write_file()
  end

  def link_book_per_page(url) do
    IO.puts "Reading url: #{url}"
    {status, body} = read_url(url)

    if status == :ok do
      {:ok, document} = Floki.parse_document(body)
      Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div > a")
      |> List.flatten()
      |> Enum.map(&format_elm(&1))
    else
      IO.puts "Error"
    end
  end

  defp read_url(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, nil}
      {:error, _} ->
        {:error, nil}
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
