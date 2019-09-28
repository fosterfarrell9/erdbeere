class StructuresController < ApplicationController
  def index
    @structures = Structure.all.to_a
  end
end