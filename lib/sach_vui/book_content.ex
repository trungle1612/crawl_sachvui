defmodule Crawler.SachVui.BookContent do
  def write(name, category, url, photo) when category == "Truyện Tranh", do: IO.puts "nil"
  def write(name, category, url, photo) do
    IO.puts("Starting write book: #{name} At url: #{url}")
    {status, body} = read_url(url)

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
    {:ok, body} = read_url(url)
    {:ok, document} = Floki.parse_document(body)

    Floki.find(document, "body > div.container > div.doc-online > p") |> Floki.text()
  end


  def list_chapter(chap_one) do
    {:ok, body} = read_url(chap_one)
    {:ok, document} = Floki.parse_document(body)

    Floki.find(document, "body > div.container > div.doc-online > div:nth-child(5) > div > ul > li > a")
    |> Enum.map(&parse_chap_info/1)
  end


  defp read_url(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
       {:ok, body}
      {:ok, %HTTPoison.Response{body: body}} ->
       {:ok, body}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
       {:error, []}
      {:error, _} ->
       {:error, []}
    end
  end

  defp parse_chap_info(chap) do
    {_, [{_, url}], [title]} =  chap

    chap_detail(title, url)
  end

  defp chap_detail(chap, url) do
    chap =  String.split(chap, ":") |> Enum.map(&String.trim/1)
    [chap_number, chap_name] = case chap do
      [_] ->
        ["", List.first(chap)]
      [_, _] ->
        chap
    end

    content = content_chap(url)
    %{number: chap_number, name: chap_name, url: url, content: content}
  end

  defp write_chapter_to_file(chap, book_name, book_category, photo) do
    create_folder("data/#{book_category}")
    create_folder("data/#{book_category}/#{book_name}")

    chap_name = remove_accent_vmn(chap.name)
    chap_name = Regex.replace(~r/\s/, chap_name, "_")
    chap_number = remove_accent_vmn(chap.number)
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

  defp remove_accent_vmn(text) do
    result = Regex.replace(~r/(À|Á|Ạ|Ả|Ã|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ)/, text, "a")
    result = Regex.replace(~r/(È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ|è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ)/, result, "e")
    result = Regex.replace(~r/(Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ|ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ)/, result, "o")
    result = Regex.replace(~r/(Ì|Í|Ị|Ỉ|Ĩ|ì|í|ị|ỉ|ĩ)/, result, "i")
    result = Regex.replace(~r/(Ư|Ừ|Ứ|Ự|Ử|Ữ|Ù|Ú|Ụ|Ủ|Ũ|ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ)/, result, "u")
    result = Regex.replace(~r/(Ỳ|Ý|Ỵ|Ỷ|Ỹ|ỳ|ý|ỵ|ỷ|ỹ)/, result, "y")

    Regex.replace(~r/(Đ|đ)/, result, "d")
  end
end
