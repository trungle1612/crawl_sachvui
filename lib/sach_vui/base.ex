defmodule Crawler.SachVui.Base do
  def read_url(url) do
    case HTTPoison.get url do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
       {:ok, body}
      {:ok, %HTTPoison.Response{body: body}} ->
       {:ok, body}
      {:error, _} ->
        {:error, []}
    end
  end

  def remove_accent_vmn(text) do
    result = Regex.replace(~r/(À|Á|Ạ|Ả|Ã|Ă|Ằ|Ắ|Ặ|Ẳ|Ẵ|Â|Ầ|Ấ|Ậ|Ẩ|Ẫ|à|á|ạ|ả|ã|â|ầ|ấ|ậ|ẩ|ẫ|ă|ằ|ắ|ặ|ẳ|ẵ)/, text, "a")
    result = Regex.replace(~r/(È|É|Ẹ|Ẻ|Ẽ|Ê|Ề|Ế|Ệ|Ể|Ễ|è|é|ẹ|ẻ|ẽ|ê|ề|ế|ệ|ể|ễ)/, result, "e")
    result = Regex.replace(~r/(Ò|Ó|Ọ|Ỏ|Õ|Ô|Ồ|Ố|Ộ|Ổ|Ỗ|Ơ|Ờ|Ớ|Ợ|Ở|Ỡ|ò|ó|ọ|ỏ|õ|ô|ồ|ố|ộ|ổ|ỗ|ơ|ờ|ớ|ợ|ở|ỡ)/, result, "o")
    result = Regex.replace(~r/(Ì|Í|Ị|Ỉ|Ĩ|ì|í|ị|ỉ|ĩ)/, result, "i")
    result = Regex.replace(~r/(Ư|Ừ|Ứ|Ự|Ử|Ữ|Ù|Ú|Ụ|Ủ|Ũ|ù|ú|ụ|ủ|ũ|ư|ừ|ứ|ự|ử|ữ)/, result, "u")
    result = Regex.replace(~r/(Ỳ|Ý|Ỵ|Ỷ|Ỹ|ỳ|ý|ỵ|ỷ|ỹ)/, result, "y")
    Regex.replace(~r/(Đ|đ)/, result, "d")
  end
end
