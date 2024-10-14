defmodule WeatherAppWeb.WeatherController do
  use WeatherAppWeb, :controller
  alias WeatherApp.WeatherService

  def index(conn, _params) do
    locations = ["Tokyo", "London", "Sydney", "Paris", "Cairo", "California", "Beijing", "Taipei", "Berlin", "Soul"]
    weather_data = WeatherService.get_weather_for_locations(locations)

    # {:ok, data}の形式なので、data部分だけを取り出してからビューに渡す
    weather_data = Enum.map(weather_data, fn
      {:ok, data} -> data
      {:error, _reason} -> %{}  # エラーの場合、空のマップを返す
    end)
    render(conn, :index, weather_data: weather_data)
  end
end
