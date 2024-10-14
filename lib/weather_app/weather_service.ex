defmodule WeatherApp.WeatherService do
  @api_key Application.get_env(:weather_app, :weather_api_key)
  @base_url "https://api.openweathermap.org/data/2.5/weather"

  def get_weather_for_locations(locations) do
    locations
    |> Enum.map(&Task.async(fn -> get_weather(&1) end))
    |> Enum.map(&Task.await/1)
  end

  defp get_weather(location) do
    url = "#{@base_url}?q=#{location}&appid=#{@api_key}"
    case Finch.build(:get, url) |> Finch.request(WeatherApp.Finch) do
      {:ok, %Finch.Response{status: 200, body: body}} ->
        {:ok, Jason.decode!(body)}
      {:ok, %Finch.Response{status: status}} ->
        {:error, "Failed to fetch weather. Status: #{status}"}
      {:error, reason} ->
        {:error, "Failed to fetch weather. Reason: #{inspect(reason)}"}
    end
  end
end
