defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view

  def mount(_params, _session, socket) do
    data = [%{type: "NONE", msg: "NONE"}]

    {:ok,
     socket
     |> assign(chat_data: data)}
  end

  def handle_event(event, params, socket) do
    case event do
      "change" ->
        handle_form_change(params, socket)

      "send" ->
        handle_send_message(socket)
    end
  end

  defp handle_form_change(params, socket) do
    {:noreply,
     socket
     |> assign(:user_message, params["message"])}
  end

  defp handle_send_message(socket) do
    user_message = socket.assigns.user_message
    send(self(), :prompt)

    {:noreply,
     socket
     |> update(:chat_data, fn data ->
       data ++ [%{type: "USER", msg: user_message}]
     end)}
  end

  def handle_info(:prompt, socket) do
    user_message = socket.assigns.user_message
    llm_response = prompt_llm(user_message)

    {:noreply,
     socket
     |> update(:chat_data, fn data ->
       data ++ [%{type: "AI", msg: llm_response}]
     end)}
  end

  defp prompt_llm(message) do
    # :timer.sleep(2000)
    # "Sure, go ahead"
    body = %{
      "contents" => [
        %{
          "parts" => [
            %{
              "text" => message
            }
          ]
        }
      ]
    }

    res =
      HTTPoison.post(
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=AIzaSyBO1d2-CxTJeWEAlqzSV6Yat26Wym0flno",
  Jason.encode!(body),
  [{"Content-Type", "application/json"}],
  recv_timeout: 300_000 # 60 seconds (1 minute)
)

    case res do
      {:ok, data} ->
        Jason.decode!(data.body)
        |> get_in(["candidates", Access.all(), "content", "parts", Access.at(0), "text"])
        |> List.first()
      {:error, error} ->
        Phoenix.Naming.humanize(error.reason)
    end
  end
end
