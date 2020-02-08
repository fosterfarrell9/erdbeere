class CachePopulator
  include Sidekiq::Worker

  def perform
    Example.all.map(&:satisfied_atoms_by_sat)
    Example.all.map(&:satisfied_atoms_by_sat_with_proof)
    Example.all.map(&:violated_atoms_by_sat)
    Example.all.map(&:violated_atoms_by_sat_with_proof)
  end
end