defmodule Crawler.SachVui.CategoryPage do
  alias Crawler.SachVui.Base

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

  def pages(url) do
    range_of_page(url)
    |> Enum.map(fn number -> "#{url}/#{number}" end)
  end

  defp range_of_page(url) do
    IO.puts("Getting: #{url} at: #{Time.utc_now}")
      case Floki.parse_document(Base.read_url(url)) do
        {:ok, document} ->
          list = Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div.col-xs-12 > ul > li")
                  |> Enum.map(&Floki.find(&1, "a"))
                  |> Enum.filter(&filter_number(&1))
                  |> Enum.map(fn x ->
                    [{_, [_,{_, number} ], _}] = x
                    {number, ""} = Integer.parse(number)
                    number
                  end)
          max_page = if length(list) == 0, do: 1, else: Enum.max(list)
          Enum.to_list(1..max_page)
        {:error, _} ->
          []
      end
  end

  def link_per_page(url) do
    {:ok, document} = Floki.parse_document(Base.read_url(url))
    Floki.find(document, "body > div.container > div.row > div.col-md-9 > div > div.panel-body > div > a")
    |> Enum.map(&format_elm(&1))
  end

  defp format_elm(elm) do
    {_, [{_, url}, _], [ {_, [{_, photo_url}, {_, title}], _}]} = elm

    %{title: title, url: url, photo: photo_url}
  end

  def write_file([]), do: IO.puts "nil"
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
      [{_, [_,{_, _number} ], _}] -> true
      _ -> false
    end
  end
end
