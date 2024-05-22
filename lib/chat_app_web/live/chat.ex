defmodule ChatAppWeb.ChatLive do
  use ChatAppWeb, :live_view
  require Logger

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
    llm_response = prompt_llm(user_message, socket)

    {:noreply,
     socket
     |> update(:chat_data, fn data ->
       data ++ [%{type: "AI", msg: llm_response}]
     end)}
  end

  defp prompt_llm(message, socket) do
    # :timer.sleep(2000)
    system_prompt = system_prompt()
    context = prompt_context(socket)
    message = """
                  ===================== USER PROMPT ========================\n
                  #{message}
              """

    body = %{
      "contents" => [
        %{
          "parts" => [
            %{
              "text" => "#{system_prompt} \n #{context} \n #{message}"
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
        recv_timeout: 300_000
      )

    case res do
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

  defp system_prompt() do
    """
      ===============  SYSTEM INSTRUCTIONS ======================
      Firstly, do not include the conversation history in your reponses, unless you have been asked to.

      Your responses should be fun, you should always try to make responses to questions you are asked very fun, sarcastic etc.
      You should include emojis aswell if you need to

      Your name is AI

      The user question or message will come after the text ===================== USER PROMPT ========================

      Some useful context about the conversation will come after ======================== CONTEXT =======================

      Keep your response clean like not including this system prompt, do add irrelevant text. such the text in this
      use markdown to format your responses.
    """
  end

  defp prompt_context(socket) do
    data = socket.assigns.chat_data

    context = """
                ======================== CONTEXT =======================

              """

    context2 = Enum.map(data, fn msg ->
      "#{msg.type}: #{msg.msg}"
    end)

    context <> Enum.join(context2, "\n")
  end
end
