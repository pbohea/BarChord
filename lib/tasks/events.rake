namespace :events do
  desc "Scrape web for Chicago live music events"
  task pull: :environment do
    puts "Running Events Search"

    require "json"
    require "http"
    require "dotenv/load"

    API_KEY  = ENV.fetch("ANTHROPIC_KEY")
    ENDPOINT = "https://api.anthropic.com/v1/messages"

    payload = {
      model: "claude-3-7-sonnet-20250219",
      max_tokens: 8192,
      tools: [
        {
          type: "web_search_20250305",
          name: "web_search",
          max_uses: 5
        },
        {
          type: "custom",
          name: "answer_json",
          description: "Return the final structured answer.",
          input_schema: {
            type: "object",
            properties: {
              events: {
                type: "array",
                items: {
                  type: "object",
                  properties: {
                    name:        { type: "string" },
                    venue:       { type: "string" },
                    address:     { type: "string" },
                    date:        { type: "string", format: "date" },
                    start_time:  { type: "string", pattern: "^\\d{2}:\\d{2}$" },
                    price:       { type: "string" },
                    ticket_url:  { type: "string", format: "uri" },
                    description: { type: "string" }
                  },
                  required: %w[name venue address date start_time],
                  additionalProperties: false
                }
              },
              source_urls: {
                type: "array",
                items: { type: "string", format: "uri" }
              }
            },
            required: ["events"],
            additionalProperties: false
          }
        }
      ],
      messages: [
        {
          role: "user",
          content: "Search for bars in Chicago with live music events in the next 7 days. Return the answer as JSON."
        }
      ]
    }

    response = HTTP
      .headers(
        "Content-Type" => "application/json",
        "x-api-key"    => API_KEY,
        "anthropic-version" => "2023-06-01"
      )
      .post(ENDPOINT, body: JSON.dump(payload))

    puts JSON.pretty_generate(JSON.parse(response.body))
  end
end
