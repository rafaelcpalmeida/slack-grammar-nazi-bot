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
        changed = false

        if /(.*[áâéêíóôú]*)(mente|zinh[ao]s?)/i.match(text)
            text = self.remove_accents(text)

            changed = true
        end

        if /(in)?d([ei])s(.{3,})/i.match(text)
            pieces = text.scan(/(in)?d([ei])s(.{3,})/i)
            puts pieces

            text = self.attempt_correction(text, "distraído")

            changed = true
        end

        unless changed
            return {'status' => 'not ok', 'text' => ""}
        else
            #return {'status' => 'ok', 'text' => "*#{text.capitalize} :face_palm: :fire:"}
            return {'status' => 'ok', 'text' => "*#{text} :face_palm: :fire:"}
        end
    end

    def self.remove_accents(word)
        word.tr('áâéêíóôúÁÂÉÊÍÓÔÚ', 'aaeeioouAAEEIOOU')
    end
    
    def self.attempt_correction(given_word, proposed_word)
        if !self.word_exists(given_word) and self.word_exists(proposed_word)
            return proposed_word
        end
    end

    def self.word_exists(word)
        return File.readlines("pt.dic").grep(/#{word}/).size > 0
    end
end

GrammarNaziBot.run