class CachePopulator
  include Sidekiq::Worker

  def perform
    Example.all.map(&:satisfied_atoms)
    Example.all.map(&:satisfied_atoms_with_proof)
    Example.all.map(&:violated_atoms)
    Example.all.map(&:violated_atoms_with_proof)
    Property.all.map(&:positive_hardcoded_facts)
    Property.all.map(&:negative_hardcoded_facts)
    Property.all.map(&:positive_derived_examples)
    Property.all.map(&:negative_derived_examples)
  end
end