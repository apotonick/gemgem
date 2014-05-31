class Rating::Cell < Cell::Concept
  property :comment
  property :created_at
  property :id

  def show
    render
  end

  def status
    link_to created_at, rating_path(id)
  end
end
