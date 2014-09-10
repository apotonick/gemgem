class Thing::Cell < Cell::Concept
  class Row < self # inherit views thing/views/.
    include ActionView::Helpers::AssetTagHelper

    property :name
    property :id

    def show
      render
    end
  end
end