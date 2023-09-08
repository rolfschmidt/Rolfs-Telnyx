# Copyright (C) 2012-2023 Zammad Foundation, https://zammad-foundation.org/

class Channel::Driver::Sms::Telnyx
  NAME = 'sms/telnyx'.freeze

  # Style/OptionalBooleanParameter
  def send(options, attr, _notification = false) # rubocop:disable Style/OptionalBooleanParameter
    Rails.logger.info "Sending SMS to recipient #{attr[:recipient]}"

    return true if Setting.get('import_mode')

    Rails.logger.info "Backend sending Telnyx SMS to #{attr[:recipient]}"
    begin
      send_create(options, attr)

      true
    rescue => e
      message = __('Error while performing request to Telnyx')
      Rails.logger.error message
      Rails.logger.error e
      raise message
    end
  end

  def send_create(options, attr)
    require 'telnyx'

    Telnyx.api_key = options[:token]
    Telnyx::Message.create(
      from: options[:sender],
      to:   attr[:recipient],
      text: attr[:message],
    )
  end

  def self.definition
    {
      name:         'Telnyx',
      adapter:      'sms/telnyx',
      notification: [
        { name: 'options::token', display: __('API Token'), tag: 'input', type: 'text', limit: 200, null: false, placeholder: 'YOUR_API_KEY' },
        { name: 'options::sender', display: __('Sender'), tag: 'input', type: 'text', limit: 200, null: false, placeholder: '+18665552368' },
      ]
    }
  end
end
