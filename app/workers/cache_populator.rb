class CachePopulator
  include Sidekiq::Worker

  def perform
    examples = Example.all
    examples.each do |e|
      ExampleSatisfier.perform_async(e.id)
      ExampleViolator.perform_async(e.id)
    end
  end
end

class ExampleSatisfier
  include Sidekiq::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.satisfied_atoms_with_proof
    example.satisfied_atoms
  end
end

class ExampleViolator
  include Sidekiq::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.satisfied_atoms_with_proof
    example.satisfied_atoms
  end
end

class PropertyPositiveFactsAndExamples
  include Sidekiq::Worker

  def perform(property_id)
    property = Property.find(property_id)
    property.positive_hardcoded_facts
    property.positive_derived_examples
  end
end

class PropertyNegativeFactsAndExamples
  include Sidekiq::Worker

  def perform(property_id)
    property = Property.find(property_id)
    property.negative_hardcoded_facts
    property.negative_derived_examples
  end
end

