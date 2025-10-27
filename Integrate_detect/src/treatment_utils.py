def get_treatment(snake_name: str, treatment_df, chat_history, llm) -> str:
    row = treatment_df[treatment_df["scientific_name"].str.lower() == snake_name.lower()]
    if not row.empty:
        info = row.iloc[0].to_dict()

        # Prepare prompt with full chat history
        history_str = ""
        for sender, msg in chat_history:
            if sender == "You":
                history_str += f"User: {msg}\n"
            else:
                history_str += f"Assistant: {msg}\n"

        prompt = (
            history_str +
            f"You are a medical expert. Based on this data: {info}, "
            f"what should a person do immediately if bitten by a {snake_name}? "
            f"Give step-by-step first aid and antivenom details if available."
        )

        output = llm(prompt, max_tokens=512)
        return output["choices"][0]["text"].strip()
    else:
        return f"No treatment info found for {snake_name}."
