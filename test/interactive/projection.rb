require_relative 'interactive_init'

context "Projection" do
  entity = Projection::Controls::Entity::New.example
  projection = Projection::Controls::Projection::Example.build(entity)
  event = Projection::Controls::Event.example

  fixture(
    Projection,
    projection,
    event
  ) do |fixture|

    fixture.assert_attributes_copied([
      { :example_id => :id },
      :amount
    ])

    fixture.assert_transformed_and_copied(:time) { |v| Time.parse(v) }
    fixture.assert_transformed_and_copied(:processed_time => :updated_time) { |v| Time.parse(v) }
  end
end
