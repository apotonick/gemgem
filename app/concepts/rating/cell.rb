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
    link_to model.thing.name, thing_path(model.thing.id) # FIXME: allow super.
  end


  class Form < Cell::Concept
    inherit_views Rating::Cell

    include ActionView::Helpers::FormHelper # TODO: fix in simple_form.
    include SimpleForm::ActionViewExtensions::FormHelper
    def dom_class(*)
      :rating
    end
    def dom_id(*)
      1
    end

    def show
      render :form
    end
  end
end
