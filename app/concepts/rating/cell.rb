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

  class Row < Cell::Concept
    inherit_views Rating::Cell

    include ActionView::Helpers::DateHelper
    include Rails::Timeago::Helper

    def show
      return unless model.user
      # return _prefixes.inspect
      # model.user.email.inspect

      render :row
    end

  private
    def weight
      model.weight == 1 ? :positive : :negative
    end

    def date
      timeago_tag model.created_at, limit: 99.days.ago
    end

    alias_method :rating, :model
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
