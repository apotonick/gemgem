class Thing::Cell < Cell::Concept
  class Row < self # inherit views thing/views/.
    include ActionView::Helpers::AssetTagHelper
    include ActionView::Helpers::TextHelper

    property :name
    property :id
    property :image

    def show
      render
    end

  private
    def avatar
      # return %{<i class="fi-layout" style="font-size: 42px"></i>}.html_safe unless image.exists?
      return image_tag("thing.png", width: 36) unless image.exists? # TODO: package into cell's images/ ?
      image_tag(image[:thumb].url, width: 36)
    end

    def count
      count = model.ratings.count
      pluralize(count, 'comment')
    end
  end
end