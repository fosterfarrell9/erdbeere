# coding: utf-8

class AtomValidator < ActiveModel::Validator
  def validate(a)
    if a.satisfies.is_a?(Property)
      return if a.satisfies.structure.related_structures.include?(a.stuff_w_props.structure)
      a.errors[:base] << 'Type mismatch between satisfies.structure and stuff_w_props.structure'
    elsif a.satisfies.is_a?(Atom)
      return if a.stuff_w_props.structure.building_blocks.map(&:structure).map(&:related_structures).flatten.include?(a.satisfies.structure)
      a.errors[:base] << 'There is no building block that matches satisfies.structure'
    else
      a.errors[:base] << 'Something srsly fucked up happened'
    end
  end
end

class Atom < ApplicationRecord
  has_many :premises
  has_many :implications, through: :premises

  belongs_to :stuff_w_props, polymorphic: true
  belongs_to :satisfies, polymorphic: true
  has_many :atoms, as: :satisfies
  has_many :axioms

  validates :stuff_w_props, presence: true
  validates :satisfies, presence: true
  validates :satisfies_id,
            uniqueness: { scope: [:stuff_w_props, :satisfies_type] }
  validates_with AtomValidator

  after_create :touch_potentially_relevant_examples
  after_destroy :touch_potentially_relevant_examples
  after_create :create_trivial_implications
  before_destroy :destroy_dependent_stuff

  def create_trivial_implications
    satisfies.implies! self if satisfies.is_a?(Atom)
  end

  def touch_potentially_relevant_examples
    Example.where(structure: satisfies.structure)
           .update_all(updated_at: Time.now)
  end

  def to_s
    "#{deep_stuff_w_props_name} *IS* #{property.name}"
  end

  def to_atom
    self
  end

  def implies!(atom)
    [self].implies!(atom)
  end

  def is_equivalent!(atoms)
    [self].is_equivalent! atoms
  end

  def structure
    stuff_w_props.structure
  end

  def property
    return satisfies.property unless satisfies.is_a?(Property)
    satisfies
  end

  def deep_stuff_w_props_name
    return stuff_w_props.name if satisfies.is_a?(Property)
    stuff_w_props.name + '.' + satisfies.stuff_w_props.name
  end

  def related_implications
    Implication.where(id: premises.pluck(:implication_id))
               .or(Implication.where(implies: self))
  end

  def destroy_dependent_stuff
    related_implications.delete_all
    axioms.destroy_all
    premises.destroy_all
  end
end
