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
  end

  factory :category do
    user
  end
end
