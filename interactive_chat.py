import openai
import argparse


def chat_with_ai(api_url, model_name, api_token):
    client = openai.OpenAI(
        base_url=api_url,
        api_key=api_token,
    )

    messages = []

    print("AI Chat Assistant (type 'quit' to exit)")
    print("-" * 40)

    while True:
        user_input = input("\nYou: ").strip()

        if user_input.lower() in ['quit', 'exit', 'bye']:
            print("Goodbye!")
            break

        if not user_input:
            continue

        messages.append({"role": "user", "content": user_input})

        try:
            response = client.chat.completions.create(
                model=model_name,
                messages=messages,
            )

            ai_response = response.choices[0].message.content
            messages.append({"role": "assistant", "content": ai_response})

            print(f"\nAI: {ai_response}")

        except Exception as e:
            print(f"Error: {e}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Chat with GPT-OSS-120B model")
    parser.add_argument("--api-url", required=True, help="API base URL (e.g., http://localhost:8010/v1)")
    parser.add_argument("--model-name", required=True, help="The model name")
    parser.add_argument("--api-token", required=True, help="API authentication token")

    args = parser.parse_args()

    chat_with_ai(args.api_url, args.model_name, args.api_token)
