class Thing::Cell < Cell::Concept
  class Row < self # inherit views thing/views/.
    property :name
    property :id

    def show
      content_tag :li do
        link_to name, thing_path(id)
      end
    end
  end
end