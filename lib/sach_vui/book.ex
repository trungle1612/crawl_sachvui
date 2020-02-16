defmodule Crawler.SachVui.Book do
  alias Crawler.SachVui.BookContent

  def download do
    book_links()
    |> Enum.map(&parse_info(&1.url, &1.photo))
    |> Enum.each(fn info ->
      {title, category, url, photo} = info
      BookContent.write(title, category, url, photo)
    end)
  end

  defp read_url(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
       {:ok, body}
      {:ok, %HTTPoison.Response{body: body}} ->
       {:ok, body}
      {:error, _} ->
        {:error, nil}
    end
  end

  defp parse_info(url, photo) do
    {status, body} = read_url(url)
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
