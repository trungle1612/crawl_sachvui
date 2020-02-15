defmodule Crawler.SachVui.CategoryPage do
  # @url "https://sachvui.com/the-loai/tam-ly-ky-nang-song.html"
  def all_link do
    category()
    |> Enum.map(fn x ->
      [_, url] = x
      String.trim(url)
    end)
    |> Enum.map(&pages(&1))
    |> List.flatten()
    |> write_file()
  end

  def range_of_page(url) do
    try do
      IO.puts("Getting: #{url} at: #{Time.utc_now}")
      {:ok, document} = Floki.parse_document(read_url(url))
      # {_, [_, {_, max_page}], _} = 
      list = Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div.col-xs-12 > ul > li")
      |> Enum.map(&Floki.find(&1, "a"))
      |> Enum.filter(&filter_number(&1))
      |> Enum.map(fn x ->
        [{_, [_,{_, number} ], _}] = x
        {number, ""} = Integer.parse(number)
        number
      end)
      # |> List.first()
      max_page = if length(list) == 0, do: 1, else: Enum.max(list)

      # {max_page, ""} = Integer.parse(max_page)
      Enum.to_list(1..max_page)
    rescue
      e in CompileError -> IO.puts "Error"
      e in Enum.EmptyError -> IO.puts "Error found"
    end
  end

  def pages(url) do
    range_of_page(url)
    |> Enum.map(fn number -> "#{url}/#{number}" end)
  end

  def link_per_page(url) do
    {:ok, document} = Floki.parse_document(read_url(url))
    Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div > a")
    |> Enum.map(&format_elm(&1))
  end

  defp read_url(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        nil
    end
  end

  defp format_elm(elm) do
    {_, [{_, url}, _], [ {_, [{_, photo_url}, {_, title}], _}]} = elm

    %{title: title, url: url, photo: photo_url}
  end

  def write_file(file) do
    File.write!("data/category_links.txt", :erlang.term_to_binary(file))
  end

  def category do
    File.read!('data/category.txt') 
    |> String.split("\n")
    |> Enum.map(fn x ->
      String.split(x, "|", trim: true)
    end)
    |> Enum.filter(&length(&1) > 0)
  end

  def filter_number(elm) do
    case elm do
      [{_, [_,{_, number} ], _}] -> true
      _ -> false
    end
  end
end
