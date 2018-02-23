require 'slack-ruby-bot'

class GrammarNaziBot < SlackRubyBot::Bot
    scan(/./) do |client, data, match|
        message_status = self.analyze_word(data.text)
        unless message_status['status'] != 'ok'
            client.web_client.chat_postMessage(
                channel: data.channel,
                as_user: true,
                parse: 'full',
                attachments: [
                {
                    text: message_status['text'],
                    color: '#FF0000',
                }
                ]
            )
        end
    end

    def self.analyze_word(text)
        if /(.*[áâéêíóôú]*)(mente|zinh[ao]s?)/.match(text)
            text = self.remove_accents(text)

            return {'status' => 'ok', 'text' => "*#{text.capitalize} :face_palm: :fire:"}
        end

        {'status' => 'not ok', 'text' => ""}    
    end

    def self.remove_accents(word)
        word.tr('áâéêíóôúÁÂÉÊÍÓÔÚ', 'aaeeioouAAEEIOOU')
    end
end

GrammarNaziBot.run