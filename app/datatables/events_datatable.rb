class EventsDatatable
  include Rails.application.routes.url_helpers
  delegate :params, :h, :link_to, :number_to_currency, :image_tag, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: Event.with_filters.with_translations(I18n.locale).count,
      iTotalDisplayRecords: events.total_entries,
      aaData: data
    }
  end

private

  def data
    events.map do |event|
      [
        link_to(I18n.t("helpers.links.view"), admin_event_path(:id => event.id, :locale => I18n.locale), :class => 'btn btn-mini'),
        event.start_datetime_formatted,
        event.end_datetime_formatted,
        event.headline,
        event.categories.present? ? event.categories.map{|x| x.name}.join(', ') : nil,
        event.tags.present? ? event.tags.map{|x| x.name}.join(', ') : nil,
        action_links(event)
      ]
    end
  end

  def action_links(event)
    x = ""
    x << link_to(I18n.t("helpers.links.edit"),
                    edit_admin_event_path(:id => event.id, :locale => I18n.locale), :class => 'btn btn-mini')
    x << " "
    x << link_to(I18n.t("helpers.links.destroy"),
                    admin_event_path(:id => event.id, :locale => I18n.locale),
                    :method => :delete,
								    :data => { :confirm => I18n.t("helpers.links.confirm") },
                    :class => 'btn btn-mini btn-danger')
    x << "<br /><br />"
    x << I18n.t('app.common.added_on', :date => I18n.l(event.created_at, :format => :short))
    return x.html_safe
  end

  def events
    @events ||= fetch_events
  end

  def fetch_events
    events = Event.with_filters.with_translations(I18n.locale).order("#{sort_column} #{sort_direction}")
    events = events.page(page).per_page(per_page)
    if params[:sSearch].present?
      search_qry = "DATE_FORMAT(events.start_date, '%Y-%m-%d') like :search or event_translations.headline like :search or event_translations.story like :search "  
      search_qry << "or category_translations.name like :search or category_translations_categories.name like :search "
      events = events.where(search_qry, search: "%#{params[:sSearch]}%")
    end
    events
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[events.start_date events.start_date events.end_date event_translations.headline category_translations.name category_translations_categories.name events.created_at]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
