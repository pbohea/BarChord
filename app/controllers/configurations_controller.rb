class ConfigurationsController < ApplicationController
  def ios_v1
    render json: {
      settings: {},
      rules: [
        {
          patterns: [
            "/new$",
            "/edit$"
          ],
          properties: {
            context: "modal"
          }
        },
        {
          patterns: [
            "^/events/map$"
          ],
          properties: {
            view_controller: "map"
          }
        }
      ]
    }
  end
end
