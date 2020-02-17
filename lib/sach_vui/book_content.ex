defmodule Crawler.SachVui.BookContent do
  alias Crawler.SachVui.Base

  def write(name, category, url, photo) when category == "Truyện Tranh", do: IO.puts "nil"
  def write(name, category, url, photo) do
    IO.puts("Starting write book: #{name} At url: #{url}")
    {status, body} = Base.read_url(url)

    list = case status do
      :ok ->
        {:ok, document} = Floki.parse_document(body)
        Floki.find(document, "#list-chapter > li > a")
      :error -> []
    end


    if length(list) == 0 do
      {:nil, "Just read online"}
    else
      List.first(list)
      |> Floki.attribute("href")
      |> List.first()
      |> list_chapter()
      |> Enum.each(&write_chapter_to_file(&1, name, category, url))
    end
    IO.puts("Done!!")
  end

  def content_chap(url) do
    {:ok, body} = Base.read_url(url)
    {:ok, document} = Floki.parse_document(body)

    Floki.find(document, "body > div.container > div.doc-online > p") |> Floki.text()
  end


  def list_chapter(chap_one) do
    {:ok, body} = Base.read_url(chap_one)
    {status, document} = Floki.parse_document(body)
    selector = "body > div.container > div.doc-online > div:nth-child(5) > div > ul > li"
    selector = "body > div.container > div.doc-online > div:nth-child(5) > div > ul > li > a"

    Floki.find(document, "body > div.container > div.doc-online > div:nth-child(5) > div > ul > li > a")
    |> Enum.map(&parse_chap_info/1)
  end

  defp parse_chap_info(chap) do
    [url] = Floki.attribute(chap, "href")
    title = Floki.text(chap)

    chap_detail(title, url)
  end

  defp chap_detail(title, url) do
    title =  String.split(title, ":", parts: 2) |> Enum.map(&String.trim/1)
    [chap_number, chap_name] = case title do
      [_] ->
        ["", List.first(title)]
      _ ->
        title
    end

    content = content_chap(url)
    %{number: chap_number, name: chap_name, url: url, content: content}
  end

  defp write_chapter_to_file(chap, book_name, book_category, photo) do
    create_folder("data/#{book_category}")
    create_folder("data/#{book_category}/#{book_name}")

    chap_name = Base.remove_accent_vmn(chap.name)
    chap_name = Regex.replace(~r/\s/, chap_name, "_")
    chap_number = Base.remove_accent_vmn(chap.number)
    chap_number = Regex.replace(~r/\s/, chap_number, "_")

    {:ok, file} = File.open("data/#{book_category}/#{book_name}/#{chap_number}_#{chap_name}.txt", [:write, :utf8])
    IO.write(file, "#{chap.number} : #{chap.name}\n")
    IO.write(file, "Link:  #{chap.url}\n")
    IO.write(file, "Cover: #{photo}\n")
    IO.write(file, "Nội dung:\n #{chap.content}")

    File.close(file)
  end

  defp create_folder(path) do
    if !File.dir?(path), do: File.mkdir(path)
  end
end
