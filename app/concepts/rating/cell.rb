class Rating::Cell < Cell::Concept
  property :comment
  property :created_at
  property :id
  property :thing

  def show
    render
  end

  def status
    link_to created_at, rating_path(id) # DISCUSS: why not rating.url[.self]?
  end

  def thing
    # link_to super.name, thing_path(super.id)
    link_to model.thing.name, thing_path(model.thing.id)
  end
end
