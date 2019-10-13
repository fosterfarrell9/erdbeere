class ImplicationUniqueness < ActiveModel::Validator
  # given a set of atoms (a premise) and an implies-atom, the implication should
  # be unique. if rails were able to cope with this, it would just be
  # validates :implies, uniqueness: { scope: :atoms }
  def validate(obj)
    matches = (Implication.all.to_a.find_all do |i|
      i.implies == obj.implies && i.atoms.to_a == obj.atoms.to_a
    end) - [obj]
    obj.errors[:base] << 'duplicate found' unless matches.empty?
  end
end

class Implication < ApplicationRecord
  # a premise is a collection of atoms connected by a logical AND
  # "has_many :premises" should be "belongs_to_many :premises".
  has_many :premises
  has_many :atoms, through: :premises
  belongs_to :implies, class_name: 'Atom', touch: true
  has_many :explanations, as: :explainable

  validates :implies, presence: true
  validates_with ImplicationUniqueness

  def to_s
    base_struct = implies.stuff_w_props.structure
    s = '*IF* '
    s << atoms.map { |a| '(' + a.to_s + ')' }.join(' *AND* ')
    s << " *THEN* #{base_struct.name} *IS* #{implies.property.name}"
    s
  end

  def self.to_a
    Implication.includes(:atoms, :implies).map { |i| [i.atoms_ids, i.implies_id] }
  end

  def self.to_dimacs
    dimacs = ''
    Implication.includes(:atoms, :implies).all.each do |i|
      i.atoms.each do |a|
        dimacs += "-#{a.id} "
      end
      dimacs += "#{i.implies.id} 0 \n"
    end
    dimacs
  end

  def self.to_dimacs_cached
    Rails.cache.fetch('implication_dimacs') do
      self.to_dimacs
    end
  end

  def self.to_dimacs_file
    temp_file = Tempfile.new
    File.open(temp_file, 'w') do |f|
      f.write dimacs = "p cnf #{Atom.count} #{Implication.count} \n"
      f.write self.to_dimacs
    end
    temp_file
  end
end
