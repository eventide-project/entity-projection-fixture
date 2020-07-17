# EntityProjection Fixtures

[TestBench](http://test-bench.software/) fixtures for the [EntityProjection](https://github.com/eventide-project/entity-projection) library

The EntityProjection Fixtures library provides [TestBench test fixtures](http://test-bench.software/user-guide/fixtures.html) for testing objects that are implementations of Eventide's [EntityProjection](http://docs.eventide-project.org/user-guide/projection.html). The projection test abstractions simplify and generalize projection tests, reducing the test implementation effort and increasing test implementation clarity.

## Fixtures

A fixture is a pre-defined, reusable test abstraction. The objects under test are specified at runtime so that the same standardized test implementation can be used against multiple objects.

A fixture is just a plain old Ruby object that includes the TestBench API. A fixture has access to the same API that any TestBench test would. By including the `TestBench::Fixture` module into a Ruby object, the object acquires all of the methods available to a test script, including context, test, assert, refute, assert_raises, refute_raises, and comment.

## Projection Fixture

The `EntityProjection::Fixtures::Projection` fixture tests the projection of an event onto an entity. It tests that the attributes of event are copied to the entity. The attributes tested can be limited to a subset of attributes by specifying a list of attribute names, and a map can be provided to compare different attributes to each other.

``` ruby
class SomeEntity
  include Schema::DataStructure

  attribute :id, String
  attribute :amount, Numeric, default: 0
  attribute :time, ::Time
  attribute :other_time, ::Time
end

class SomeEvent
  include Messaging::Message

  attribute :example_id, String
  attribute :amount, Numeric, default: 0
  attribute :time, String
  attribute :some_time, String
end

class SomeProjection
  include EntityProjection

  entity_name :some_entity

  apply SomeEvent do |some_event|
    some_entity.id = some_event.example_id
    some_entity.amount = some_event.amount
    some_entity.time = Time.parse(some_event.time)
    some_entity.other_time = Time.parse(some_event.some_time)
  end
end

context "SomeProjection" do
  some_event = SomeEvent.new
  some_event.example_id = SecureRandom.uuid
  some_event.amount = 11
  some_event.time = Time.utc(2000)
  some_event.some_time = Time.utc(2000) + 1

  some_entity = SomeEntity.new

  fixture(
    EntityProjection::Fixtures::Projection,
    SomeProjection,
    some_entity,
    some_entity
  ) do |fixture|

    fixture.assert_attributes_copied([
      { :example_id => :id },
      :amount
    ])

    fixture.assert_time_converted_and_copied(:time)
    fixture.assert_time_converted_and_copied(:some_time => :other_time)
  end
end
```

Running the test is no different than [running any TestBench test](http://test-bench.software/user-guide/running-tests.html). In its simplest form, running the test is done by passing the test file name to the `ruby` executable.

``` bash
ruby test/projection.rb
```

The test script and the fixture work together as if they are the same test.

```
SomeProjection
  Apply SomeEvent to SomeEntity
    Schema Equality: SomeEntity, SomeEvent
      Attributes
        example_id => id
        amount
    Time converted and copied
      time
    Time converted and copied
      some_time => other_time
```

The output from the "SomeProjection" line-downward is from the Equality fixture.

### Detailed Output

The fixture will print more detailed output if the `TEST_BENCH_DETAIL` environment variable is set to `on`.

``` bash
TEST_BENCH_DETAIL=on ruby test/projection.rb
```

```
SomeProjection
  Projection Class: SomeProjection
  Apply SomeEvent to SomeEntity
    Event Class: SomeEvent
    Entity Class: SomeEntity
    Schema Equality: SomeEntity, SomeEvent
      Control Class: SomeEntity
      Compare Class: SomeEvent
      Attributes
        example_id => id
          Control Value: "00000001-0000-4000-8000-000000000000"
          Compare Value: "00000001-0000-4000-8000-000000000000"
        amount
          Control Value: 11
          Compare Value: 11
    Time converted and copied
      time
        Event Time: 2000-01-01T00:00:00.000Z
        Entity Time: 2000-01-01 12:00:00.000 UTC
    Time converted and copied
      some_time => other_time
        Event Time: 2000-01-01T00:00:00.011Z
        Entity Time: 2000-01-01 12:00:00.011 UTC
```

## License

The `entity-projection-fixtures` library is released under the [MIT License](https://github.com/eventide-project/entity-projection-fixtures/blob/master/MIT-License.txt).
