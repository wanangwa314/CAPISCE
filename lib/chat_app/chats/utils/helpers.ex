defmodule ChatApp.Utils.Helpers do
  require Logger

  def extract_llm_response(response) do
    case response do
      {:ok, data} ->
        Jason.decode!(data.body)
        |> get_in(["candidates", Access.all(), "content", "parts", Access.at(0), "text"])
        |> List.first()
        |> case do
          nil -> "I have no more responses sorry."
          text -> text
        end
        |> String.replace("<p>", "")
        |> String.replace("</p>", "")
        |> Earmark.as_html()
        |> case do
          {:ok, md, _list} -> md
          {:error, error, _list} -> Logger.error(error)
        end

      {:error, error} ->
        Phoenix.Naming.humanize(error.reason)
    end
  end
end
