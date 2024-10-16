# Elixir で並行処理を使った天気アプリの作成

## はじめに

今回は、Elixir を使って世界各地の天気情報を取得するアプリを作成しました。
Elixir の特徴である並行処理にフォーカスして、その実装方法とメリットについて解説します。

## Elixir とは

Elixir は並行処理に強い関数型プログラミング言語です。
Elixir では、並行処理が軽量で、タスク間の切り替えが高速です。
アプリケーション内に数千もの並行プロセスを持つことは珍しくありません。
並行処理は、特に API から複数のデータを同時に取得したい場面で非常に有効です。(追記)
Elixir の並行処理モデルを活用することで、処理の効率を大幅に向上させることができます。
このブログでは、Elixir の並行処理を活かしてどのようにアプリを作ったのかを詳しく説明します。

## 並行し処理と並列処理の違い

よく勘違いされがちですが、並行処理と並列処理は違います。

### 並行処理（Concurrency）

並行処理は、複数のタスクを「同時に進行させることができる」設計や仕組みを指します。
並行処理では、実際にタスクが同時に実行されているかどうかは問題ではなく、複数のタスクが交互に進行している状態を意味します。

例えば、1 つの CPU しかない場合でも、短い時間でタスク間を切り替えることで、複数のタスクがあたかも同時に実行されているかのように見せることが可能です。
英語表記の方を見ていただくとわかる通り、現在(Currency)を共有(Con)しています。
javascript の非同期処理はシングルスレッドなので並行処理です。(https://qiita.com/klme_u6/items/ea155f82cbe44d6f5d88)

### 並列処理（Parallelism）

並列処理は、物理的に複数のコアや CPU を使って、タスクを「同時に実行する」ことを指します。
並列処理では、タスクが実際に同時に進行し、それぞれが独立したプロセッサやコアで動作するため、全体の処理速度を大幅に向上させることができます。

並列処理が可能なシステムでは、複数のコアやスレッドが同時に動作し、独立したタスクを並行して処理するため、並行処理よりも高いパフォーマンスが期待できます。

---

## アプリの概要

作成したアプリは、複数の都市の天気情報を API から取得し、並行処理を利用して効率的にデータを表示するものです。
OpenWeatherMap API を利用し、HTTP リクエストを並列で送信しています。

具体的な機能としては、以下の 世界 10 の都市の天気情報を取得して、UI 上に表示するシンプルなアプリです。

---

## 使用した技術

- **Elixir**: 並行処理に強い、関数型プログラミング言語。
- **Phoenix**: Elixir の Web フレームワーク。Rails のような MVC フレームワークです。
- **Finch**: 高性能な HTTP クライアントライブラリ。
- **OpenWeatherMap API**: 天気情報を取得する API。

---

## 並行処理のポイント

Elixir では、並行処理は非常に簡単に実装できます。
`Task`モジュールを使うことで、各都市の天気情報を非同期で取得し、同時に複数のリクエストを処理することができます。

---

## 並行処理の実装

次に、実際に並行処理を用いた天気情報の取得方法を見ていきます。以下のコードは、各都市の天気情報を並行して取得する部分の実装です。

1. **`Task.async/1`**  
   各都市の天気情報を取得するために、`Task.async/1`を使って非同期タスクを作成しています。これにより、各リクエストが並行して実行され、リクエストの待ち時間を短縮できます。

2. **`Task.await/1`**  
   作成したタスクを待ち、リクエストが完了したら結果を取得します。

たったこれだけです。Elixir では`Task`モジュールを使うだけで簡単に並行処理を実装できます。

```elixir
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
```

---

## UI の表示

天気表示は今回の主題ではないので AI に考えてもらいました。
各都市の天気情報をカード形式で表示しています。

---

## 所感

簡単な並行処理のプログラムの実装でしたが、かなり簡単に書くことができました。
ただ、現在では多くの言語で並列処理がサポートされていますし、あえて Elixir でなければいけないというシーンは少ないかなと思いました。
