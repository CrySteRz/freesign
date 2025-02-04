# frozen_string_literal: true
module Embed
  module Api
    class SubmitterFormViewsController < ApplicationController
      protect_from_forgery with: :null_session # To handle CSRF protection for API requests
      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token
      skip_authorization_check

      def create
        submitter = Submitter.find_by!(slug: params[:submitter_slug])

        submitter.opened_at = Time.current
        submitter.save

        SubmissionEvents.create_with_tracking_data(submitter, 'view_form', request)

        SendFormViewedWebhookRequestJob.perform_later(submitter)

        render json: {}
      end
    end
  end
end
