class TranslateExplanations < ActiveRecord::Migration[6.0]
  def self.up
    Explanation.create_translation_table!({
      :title => :string,
      :text => :text
    }, {
      :migrate_data => true,
      :remove_source_columns => true
    })
  end

  def self.down
    Post.drop_translation_table! :migrate_data => true
  end
end
