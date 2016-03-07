FactoryGirl.define do
  to_create { |instance| instance.save raise_on_failure: true }

  factory :user do
    name 'testuser'
    password 'i4mh4x0r'
  end

  factory :round do
    words_by
    story_by

    after(:create) do |round, _|
      create_list :word, Round.words_count, round: round
    end
  end

  factory :word do
    category
    word 'Hipsta'
    created_at DateTime.rfc3339('2012-12-22T12:39:34+00:00')
  end

  factory :category do
    user
    name ''

    factory :category_with_words do
      transient do
        words_count 5
        word_prefix 'word'
      end

      after(:create) do |category, e|
        (1...e.words_count).each do |num|
          create :word, category: category, word: "#{e.word_prefix}_#{num}"
        end
      end
    end
  end
end
