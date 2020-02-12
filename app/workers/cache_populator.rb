# CachePopulator worker
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

# ExampleSatisfier worker
class ExampleSatisfier
  include Sidekiq::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.satisfied_atoms_with_proof
    example.satisfied_atoms
  end
end

# ExampleViolator worker
class ExampleViolator
  include Sidekiq::Worker

  def perform(example_id)
    example = Example.find(example_id)
    example.satisfied_atoms_with_proof
    example.satisfied_atoms
  end
end
