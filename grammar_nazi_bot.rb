require 'slack-ruby-bot'

class GrammarNaziBot < SlackRubyBot::Bot
    scan(/./) do |client, data, _|
        message_status = analyze_word(data.text.gsub(/(?=:)(.*)(?:)/i, ' '))
        unless message_status['status'] != 'ok'
            client.web_client.chat_postMessage(
                channel: data.channel,
                as_user: true,
                parse: 'full',
                attachments: [
                {
                    text: message_status['text'],
                    color: '#FF0000'
                }
                ]
            )
        end
    end

    def self.analyze_word(text)
        changed = false

        # sózinho, sómente
        if text =~ /(.{1}[áâéêíóôú]*)(mente|zinh[ao]s?)/i
            pieces = text.scan(/(.{1}[áâéêíóôú]*)(mente|zinh[ao]s?)/i).join('')

            text = text.sub!(/(.{1}[áâéêíóôú]*)(mente|zinh[ao]s?)/i, remove_accents(pieces))

            changed = true
        end

        # destraído, distoar
        if text =~ /(in)?d([ei])s(.{3,})/i
            pieces = text.scan(/(in)?d([ei])s(.{3,})/i)

            text = text.sub!(/(in)?d([ei])s(.{3,})/i, attempt_correction(text, pieces.first.first.to_s + (pieces.first[1].to_s == 'e' ? 'dis' : 'des') + pieces.last.last.to_s))

            changed = true
        end

        # chatisse
        if text =~ /(.+i)ss(es?)/i
            pieces = text.scan(/(.+i)ss(es?)/i)

            puts 'Piece'
            puts pieces.first.first.to_s + 'c' + pieces.last.last.to_s

            text = text.sub!(/(.+i)ss(es?)/i, attempt_correction(text, pieces.first.first.to_s + 'c' + pieces.last.last.to_s))

            changed = true
        end

        if changed
            text[0] = text[0].capitalize
            return { 'status' => 'ok', 'text' => "*#{text} :face_palm: :fire:" }
        else
            return { 'status' => 'not ok', 'text' => '' }
        end
    end

    def self.remove_accents(word)
        word.tr('áâéêíóôúÁÂÉÊÍÓÔÚ', 'aaeeioouAAEEIOOU')
    end

    def self.attempt_correction(given_word, proposed_word)
        if !word_exists(given_word.downcase) && word_exists(proposed_word.downcase)
            proposed_word
        end

        given_word
    end

    def self.word_exists(word)
        !File.readlines('pt.dic').grep(/#{word}/).empty?
    end
end

GrammarNaziBot.run
